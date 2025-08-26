"""
EDA and visualization for Reddit posts and comments stored in parquet files.

Inputs (defaults assume files in repo root):
  - all_posts_after.parquet
  - all_comments_after.parquet

Outputs:
  - Charts and CSV summaries under eda/after_eda/

Notes:
  - Uses Polars for efficient parquet scanning and Pandas/Seaborn for plotting.
  - Handles missing columns gracefully; some charts may be skipped if data is absent.
  - WordClouds are optional; install wordcloud to enable.
"""

from __future__ import annotations

import os
import math
import warnings
from dataclasses import dataclass
from typing import Optional, Sequence
from pathlib import Path

import polars as pl

# Plotting libs are imported lazily to avoid import cost if only summaries are run
import matplotlib.pyplot as plt
import seaborn as sns


@dataclass
class Config:
    # Resolve defaults relative to repository root (parent of this file's directory)
    _HERE = Path(__file__).resolve().parent
    _ROOT = _HERE.parent
    posts_path: str = str(_ROOT / "all_posts_after.parquet")
    comments_path: str = str(_ROOT / "all_comments_after.parquet")
    # Always write outputs under eda/after_eda regardless of CWD
    out_dir: str = str(_HERE / "after_eda")
    # plotting limits to keep figures readable
    top_subreddits_for_bars: int = 20
    max_samples_for_length_hists: int = 200_000
    max_text_for_wordcloud_chars: int = 2_000_000  # ~2MB text cap
    max_weeks_in_plot: int = 30  # cap weekly bars to most recent N weeks


def ensure_outdir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def savefig(path: str) -> None:
    plt.tight_layout()
    plt.savefig(path, dpi=150)
    plt.close()


def write_csv(df: pl.DataFrame, path: str) -> None:
    df.write_csv(path)


def write_text(lines: Sequence[str], path: str) -> None:
    with open(path, "w", encoding="utf-8") as f:
        for ln in lines:
            f.write(ln.rstrip("\n") + "\n")


def try_wordcloud() -> Optional[type]:
    try:
        from wordcloud import WordCloud  # type: ignore

        return WordCloud
    except Exception:
        return None


def summarize_basic(cfg: Config, posts: pl.LazyFrame, comments: pl.LazyFrame) -> None:
    ensure_outdir(cfg.out_dir)

    lines: list[str] = []
    # sizes
    # robust scalar extraction from 1x1 frames
    p_n = posts.select(pl.len().alias("len")).collect()["len"][0]
    c_n = comments.select(pl.len().alias("len")).collect()["len"][0]
    lines.append(f"Posts rows: {p_n}")
    lines.append(f"Comments rows: {c_n}")

    # columns (avoid resolving full plan repeatedly)
    p_cols = posts.collect_schema().names()
    c_cols = comments.collect_schema().names()
    lines.append(f"Posts columns: {p_cols}")
    lines.append(f"Comments columns: {c_cols}")

    # subreddits
    if "subreddit" in p_cols:
        p_subs = (
            posts.select(pl.col("subreddit")).unique().collect().height
        )
        lines.append(f"Unique post subreddits: {p_subs}")
    if "subreddit" in c_cols:
        c_subs = (
            comments.select(pl.col("subreddit")).unique().collect().height
        )
        lines.append(f"Unique comment subreddits: {c_subs}")

    write_text(lines, os.path.join(cfg.out_dir, "00_summary.txt"))


def plot_counts_by_subreddit(cfg: Config, posts: pl.LazyFrame, comments: pl.LazyFrame) -> None:
    sns.set(style="whitegrid")

    if "subreddit" in posts.collect_schema().names():
        post_counts = (
            posts.group_by("subreddit").len().sort("len", descending=True).collect()
        )
        write_csv(post_counts, os.path.join(cfg.out_dir, "posts_by_subreddit.csv"))

        top = post_counts.head(cfg.top_subreddits_for_bars)
        plt.figure(figsize=(10, 6))
        sns.barplot(
            y=top["subreddit"].to_list(), x=top["len"].to_list(), color="#4C78A8"
        )
        plt.title("Posts per subreddit (top)")
        plt.xlabel("Count")
        plt.ylabel("Subreddit")
        savefig(os.path.join(cfg.out_dir, "01_posts_by_subreddit.png"))

    if "subreddit" in comments.collect_schema().names():
        comment_counts = (
            comments.group_by("subreddit").len().sort("len", descending=True).collect()
        )
        write_csv(
            comment_counts, os.path.join(cfg.out_dir, "comments_by_subreddit.csv")
        )

        top = comment_counts.head(cfg.top_subreddits_for_bars)
        plt.figure(figsize=(10, 6))
        sns.barplot(
            y=top["subreddit"].to_list(), x=top["len"].to_list(), color="#F58518"
        )
        plt.title("Comments per subreddit (top)")
        plt.xlabel("Count")
        plt.ylabel("Subreddit")
        savefig(os.path.join(cfg.out_dir, "02_comments_by_subreddit.png"))


def plot_length_stats(cfg: Config, posts: pl.LazyFrame, comments: pl.LazyFrame) -> None:
    # Comments body length distribution (sample to cap size)
    if "body" in comments.collect_schema().names():
        # Compute 99th percentile to reduce skew from extreme outliers
        q99_df = (
            comments
            .select(pl.col("body").cast(pl.Utf8).str.len_chars().alias("body_length"))
            .select(pl.col("body_length").quantile(0.99).alias("p99"))
            .collect()
        )
        p99 = float(q99_df["p99"][0]) if q99_df.height else 0.0

        # sample up to cap but only <= p99 to avoid skew
        sample = (
            comments
            .select(pl.col("body").cast(pl.Utf8).str.len_chars().alias("body_length"))
            .filter(pl.col("body_length") <= p99)
            .limit(cfg.max_samples_for_length_hists)
            .collect()
        )
        plt.figure(figsize=(10, 6))
        sns.histplot(sample.to_pandas()["body_length"], bins=50, kde=True, color="blue")
        plt.title("Comment length distribution (<= p99)")
        plt.xlabel("Length (chars)")
        savefig(os.path.join(cfg.out_dir, "03_comment_length_hist.png"))

        # Average comment length per subreddit
        if "subreddit" in comments.collect_schema().names():
            avg_len = (
                comments
                .select(
                    pl.col("subreddit"),
                    pl.col("body").cast(pl.Utf8).str.len_chars().alias("body_length"),
                )
                .group_by("subreddit")
                .agg(pl.col("body_length").mean().alias("avg_len"))
                .sort("avg_len")
                .collect()
            )
            write_csv(avg_len, os.path.join(cfg.out_dir, "avg_comment_length_by_subreddit.csv"))

            top = avg_len.tail(cfg.top_subreddits_for_bars)
            plt.figure(figsize=(10, 6))
            sns.barplot(
                y=top["subreddit"].to_list(), x=top["avg_len"].to_list(), color="#54A24B"
            )
            plt.title("Avg comment length by subreddit")
            plt.xlabel("Avg length (chars)")
            plt.ylabel("Subreddit")
            savefig(os.path.join(cfg.out_dir, "04_avg_comment_length_by_subreddit.png"))

    # Post text lengths (title + selftext)
    if "title" in posts.collect_schema().names():
        post_lengths = posts.select(
            [
                pl.col("title").cast(pl.Utf8).str.len_chars().alias("title_length"),
                pl.when(pl.col("selftext").is_not_null())
                .then(pl.col("selftext").cast(pl.Utf8).str.len_chars())
                .otherwise(0)
                .alias("selftext_length"),
            ]
        )

        # Compute p99 thresholds
        q_df = (
            post_lengths
            .select(
                pl.col("title_length").quantile(0.99).alias("p99_title"),
                pl.col("selftext_length").quantile(0.99).alias("p99_selftext"),
            )
            .collect()
        )
        p99_title = float(q_df["p99_title"][0]) if q_df.height else 0.0
        p99_self = float(q_df["p99_selftext"][0]) if q_df.height else 0.0

        # Clip to p99 and sample for plotting
        post_len = (
            post_lengths
            .filter((pl.col("title_length") <= p99_title) & (pl.col("selftext_length") <= p99_self))
            .limit(min(cfg.max_samples_for_length_hists, 100_000))
            .collect()
        )

        df = post_len.to_pandas()
        plt.figure(figsize=(10, 6))
        sns.histplot(df["title_length"], bins=50, kde=True, color="teal")
        plt.title("Post title length distribution (<= p99)")
        plt.xlabel("Length (chars)")
        savefig(os.path.join(cfg.out_dir, "05_title_length_hist.png"))

        plt.figure(figsize=(10, 6))
        sns.histplot(df["selftext_length"], bins=50, kde=True, color="purple")
        plt.title("Post selftext length distribution (<= p99)")
        plt.xlabel("Length (chars)")
        savefig(os.path.join(cfg.out_dir, "06_selftext_length_hist.png"))


def plot_scores(cfg: Config, posts: pl.LazyFrame, comments: pl.LazyFrame) -> None:
    # Posts score distribution by subreddit (boxplot over top-N subs by post count)
    if (
        "score" in posts.collect_schema().names()
        and "subreddit" in posts.collect_schema().names()
    ):
        top_subs = (
            posts.group_by("subreddit").len().sort("len", descending=True).limit(cfg.top_subreddits_for_bars)
        )
        subset = (
            posts
            .select("subreddit", "score")
            .join(top_subs.select("subreddit"), on="subreddit", how="inner")
            .collect()
        )
        if subset.height > 0:
            plt.figure(figsize=(12, 6))
            # Convert to pandas for seaborn boxplot
            sdf = subset.to_pandas()
            sns.boxplot(data=sdf, x="subreddit", y="score")
            plt.xticks(rotation=45, ha="right")
            plt.title("Post score distribution by subreddit (top)")
            savefig(os.path.join(cfg.out_dir, "07_post_scores_boxplot.png"))

    # Avg comment score per subreddit (bar)
    if (
        "score" in comments.collect_schema().names()
        and "subreddit" in comments.collect_schema().names()
    ):
        avg_score = (
            comments.group_by("subreddit").agg(pl.col("score").mean().alias("avg_score"))
            .sort("avg_score")
            .collect()
        )
        write_csv(avg_score, os.path.join(cfg.out_dir, "avg_comment_score_by_subreddit.csv"))

        top = avg_score.tail(cfg.top_subreddits_for_bars)
        plt.figure(figsize=(10, 6))
        sns.barplot(y=top["subreddit"].to_list(), x=top["avg_score"].to_list(), color="#B279A2")
        plt.title("Avg comment score by subreddit")
        plt.xlabel("Avg score")
        plt.ylabel("Subreddit")
        savefig(os.path.join(cfg.out_dir, "08_avg_comment_score_by_subreddit.png"))


def plot_time_patterns(cfg: Config, posts: pl.LazyFrame, comments: pl.LazyFrame) -> None:
    # Posts per month (requires created_utc in seconds)
    if "created_utc" in posts.collect_schema().names():
        monthly = (
            posts.select(
                pl.from_epoch(pl.col("created_utc"), "s").dt.truncate(every="1mo").alias("month")
            )
            .group_by("month")
            .len()
            .sort("month")
            .collect()
        )
        plt.figure(figsize=(12, 6))
        plt.bar(monthly["month"].dt.strftime("%Y-%m").to_list(), monthly["len"].to_list(), color="#4C78A8")
        plt.xticks(rotation=45, ha="right")
        plt.title("Posts per month")
        plt.xlabel("Month")
        plt.ylabel("Count")
        savefig(os.path.join(cfg.out_dir, "09_posts_per_month.png"))

        # Posts per week (ISO week start)
        weekly = (
            posts.select(
                pl.from_epoch(pl.col("created_utc"), "s")
                .dt.truncate(every="1w")
                .alias("week")
            )
            .drop_nulls()
            .group_by("week")
            .len()
            .sort("week")
            .collect()
        )
        # keep only the most recent N weeks to avoid long empty-looking ranges
        if weekly.height > cfg.max_weeks_in_plot:
            weekly = weekly.tail(cfg.max_weeks_in_plot)
        plt.figure(figsize=(12, 6))
        plt.bar(weekly["week"].dt.strftime("%Y-%m-%d").to_list(), weekly["len"].to_list(), color="#72B7B2")
        plt.xticks(rotation=45, ha="right")
        plt.title("Posts per week")
        plt.xlabel("Week starting")
        plt.ylabel("Count")
        savefig(os.path.join(cfg.out_dir, "09b_posts_per_week.png"))

    # Comments by hour-of-day
    if "created_utc" in comments.collect_schema().names():
        by_hour = (
            comments.select(
                pl.from_epoch(pl.col("created_utc"), "s").dt.hour().alias("hour")
            )
            .group_by("hour")
            .len()
            .sort("hour")
            .collect()
        )
        plt.figure(figsize=(12, 6))
        plt.bar(by_hour["hour"].to_list(), by_hour["len"].to_list(), color="#F58518")
        plt.title("Comments by hour of day")
        plt.xlabel("Hour")
        plt.ylabel("Count")
        savefig(os.path.join(cfg.out_dir, "10_comments_by_hour.png"))


def plot_top_authors(cfg: Config, posts: pl.LazyFrame, comments: pl.LazyFrame) -> None:
    # Posts - top authors
    if "author" in posts.collect_schema().names():
        top_authors_posts = (
            posts.group_by("author").len().sort("len", descending=True).limit(10).collect()
        )
        plt.figure(figsize=(10, 6))
        sns.barplot(
            y=top_authors_posts["author"].to_list(),
            x=top_authors_posts["len"].to_list(),
            color="green",
        )
        plt.title("Top 10 authors by posts")
        plt.xlabel("Posts")
        plt.ylabel("Author")
        savefig(os.path.join(cfg.out_dir, "11_top_post_authors.png"))

    # Comments - top authors
    if "author" in comments.collect_schema().names():
        top_authors_comments = (
            comments.group_by("author").len().sort("len", descending=True).limit(10).collect()
        )
        plt.figure(figsize=(10, 6))
        sns.barplot(
            y=top_authors_comments["author"].to_list(),
            x=top_authors_comments["len"].to_list(),
            color="orange",
        )
        plt.title("Top 10 authors by comments")
        plt.xlabel("Comments")
        plt.ylabel("Author")
        savefig(os.path.join(cfg.out_dir, "12_top_comment_authors.png"))


def plot_wordclouds(cfg: Config, posts: pl.LazyFrame, comments: pl.LazyFrame) -> None:
    WordCloud = try_wordcloud()
    if WordCloud is None:
        warnings.warn("wordcloud not installed; skipping wordclouds")
        return

    # Titles WC
    if "title" in posts.collect_schema().names():
        titles = (
            posts.select(pl.col("title").cast(pl.Utf8)).collect()["title"].to_list()
        )
        text = " ".join([t for t in titles if t])
        if len(text) > cfg.max_text_for_wordcloud_chars:
            text = text[: cfg.max_text_for_wordcloud_chars]
        wc = WordCloud(stopwords=None, background_color="white", width=1200, height=600).generate(text)
        plt.figure(figsize=(12, 6))
        plt.imshow(wc, interpolation="bilinear")
        plt.axis("off")
        plt.title("WordCloud - Post Titles")
        savefig(os.path.join(cfg.out_dir, "13_wordcloud_titles.png"))

    # Comments WC (sample to cap size)
    if "body" in comments.collect_schema().names():
        bodies = (
            comments
            .select(pl.col("body").cast(pl.Utf8))
            .limit(200_000)
            .collect()["body"].to_list()
        )
        text = " ".join([t for t in bodies if t])
        if len(text) > cfg.max_text_for_wordcloud_chars:
            text = text[: cfg.max_text_for_wordcloud_chars]
        wc = WordCloud(stopwords=None, background_color="white", width=1200, height=600).generate(text)
        plt.figure(figsize=(12, 6))
        plt.imshow(wc, interpolation="bilinear")
        plt.axis("off")
        plt.title("WordCloud - Comments (sampled)")
        savefig(os.path.join(cfg.out_dir, "14_wordcloud_comments.png"))


def main(cfg: Optional[Config] = None) -> None:
    cfg = cfg or Config()
    ensure_outdir(cfg.out_dir)

    # Validate inputs with clear messages
    if not Path(cfg.posts_path).exists():
        raise FileNotFoundError(
            f"Posts parquet not found: {cfg.posts_path}\n"
            f"Tip: Keep parquet files at repo root or set Config paths."
        )
    if not Path(cfg.comments_path).exists():
        raise FileNotFoundError(
            f"Comments parquet not found: {cfg.comments_path}\n"
            f"Tip: Keep parquet files at repo root or set Config paths."
        )

    # Lazy scan parquet files
    posts = pl.scan_parquet(cfg.posts_path)
    comments = pl.scan_parquet(cfg.comments_path)

    summarize_basic(cfg, posts, comments)
    plot_counts_by_subreddit(cfg, posts, comments)
    plot_length_stats(cfg, posts, comments)
    plot_scores(cfg, posts, comments)
    plot_time_patterns(cfg, posts, comments)
    plot_top_authors(cfg, posts, comments)
    plot_wordclouds(cfg, posts, comments)


if __name__ == "__main__":
    main()
