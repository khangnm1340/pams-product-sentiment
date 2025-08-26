# select_posts_and_comments.py
# Requires: pip install polars pyarrow

# ---- Config (edit these) ----
POSTS_FILE = "all_posts_after.parquet"
COMMENTS_FILE = "all_comments_after.parquet"
OUTPUT_FILE = "posts_and_comments.parquet"  # .parquet | .csv | .ndjson | .jsonl
TOP_K = 30
RAND_K = 20
# -----------------------------

import polars as pl


def build_selected_posts(posts_lazy: pl.LazyFrame) -> pl.LazyFrame:
    base = posts_lazy.select("name", "subreddit", "score", "title", "selftext")

    # Top-K by score per subreddit
    topk = (
        base.with_columns(
            pl.col("score")
            .rank(method="ordinal", descending=True)
            .over("subreddit")
            .alias("r_top")
        )
        .filter(pl.col("r_top") <= TOP_K)
        .drop("r_top")
    )

    # "Random"-K per subreddit using a deterministic hash of the post id
    # (works on older Polars without pl.random)
    randk = (
        base.with_columns(
            pl.col("name").hash().alias("rand_key")  # u64, deterministic
        )
        .with_columns(
            pl.col("rand_key")
            .rank(
                method="ordinal", descending=True
            )  # descending to vary selection; either way is fine
            .over("subreddit")
            .alias("r_rand")
        )
        .filter(pl.col("r_rand") <= RAND_K)
        .drop("rand_key", "r_rand")
    )

    # Union + dedup by post id
    return pl.concat([topk, randk]).unique(subset="name")


def main():
    posts = pl.scan_parquet(POSTS_FILE)
    comments = pl.scan_parquet(COMMENTS_FILE)

    selected_posts = build_selected_posts(posts)

    # Keep comments whose link_id ∈ selected post ids
    selected_comments = (
        comments.select("name", "subreddit", "score", "link_id", "parent_id", "body")
        .join(
            selected_posts.select(pl.col("name").alias("link_id")),
            on="link_id",
            how="semi",
        )
        .with_columns(pl.lit(False).alias("is_post"))
    )

    # Align post schema: body = title + "\n" + selftext
    posts_aligned = selected_posts.with_columns(
        [
            pl.lit("").alias("link_id"),
            pl.lit("").alias("parent_id"),
            (
                pl.coalesce([pl.col("title"), pl.lit("")])
                + pl.lit("\n")
                + pl.coalesce([pl.col("selftext"), pl.lit("")])
            ).alias("body"),
            pl.lit(True).alias("is_post"),
        ]
    ).drop("title", "selftext")

    final_cols = [
        "name",
        "subreddit",
        "score",
        "link_id",
        "parent_id",
        "body",
        "is_post",
    ]
    final = pl.concat(
        [
            posts_aligned.select(final_cols),
            selected_comments.select(final_cols),
        ]
    )

    # Stream to disk based on extension
    if OUTPUT_FILE.endswith(".parquet"):
        final.sink_parquet(OUTPUT_FILE)
    elif OUTPUT_FILE.endswith(".csv"):
        final.sink_csv(OUTPUT_FILE)
    elif OUTPUT_FILE.endswith(".ndjson") or OUTPUT_FILE.endswith(".jsonl"):
        final.sink_ndjson(OUTPUT_FILE)
    else:
        final.sink_parquet(OUTPUT_FILE + ".parquet")


if __name__ == "__main__":
    main()
