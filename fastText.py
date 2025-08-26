# pip install polars pyarrow fasttext-wheel  # or fasttext (if numpy<2)
import os, re, math
import polars as pl
from concurrent.futures import ProcessPoolExecutor, as_completed

MODEL_PATH = "lid.176.ftz"  # download once from fastText
THRESH = 0.80  # prob threshold
CHUNK = 50_000  # tune to your RAM/CPU

# --- text cleaning (no newlines for fastText) ---
_url = re.compile(r"https?://\S+")
_ws = re.compile(r"\s+")


def _clean(s: str) -> str:
    if not s:
        return ""
    s = _url.sub("", s)
    s = s.replace("\r", " ").replace("\n", " ")
    return _ws.sub(" ", s).strip()


# --- worker process: load model once per process ---
_ft = None


def _init(model_path: str):
    global _ft
    import fasttext

    _ft = fasttext.load_model(model_path)


def _predict_chunk(texts: list[str], thresh: float) -> list[bool]:
    # clean + batch predict
    cleaned = [_clean(t) for t in texts]
    # optionally skip obvious empties quickly
    keep_idx = [
        i
        for i, t in enumerate(cleaned)
        if len(t) >= 5 and t not in {"[removed]", "[deleted]"}
    ]
    if not keep_idx:
        return [False] * len(texts)

    # fastText batch predict
    labels, probs = _ft.predict([cleaned[i] for i in keep_idx], k=1)
    out = [False] * len(texts)
    for slot, i in enumerate(keep_idx):
        lang = labels[slot][0].replace("__label__", "")
        p = float(probs[slot][0])
        out[i] = (lang != "en") and (p >= thresh)
    return out


if __name__ == "__main__":
    # avoid oversubscription when using multiple processes
    os.environ.setdefault("OMP_NUM_THREADS", "1")

    # read just the body column (1M rows fits fine)
    df = pl.scan_parquet("all_comments_after.parquet").select("body").collect()

    bodies = df["body"].to_list()
    n = len(bodies)

    # shard work
    tasks = []
    with ProcessPoolExecutor(
        max_workers=os.cpu_count(), initializer=_init, initargs=(MODEL_PATH,)
    ) as ex:
        for start in range(0, n, CHUNK):
            end = min(start + CHUNK, n)
            tasks.append((start, ex.submit(_predict_chunk, bodies[start:end], THRESH)))

        mask = [False] * n
        for start, fut in tasks:
            part = fut.result()
            mask[start : start + len(part)] = part

    # filter the ORIGINAL parquet with mask
    out = pl.DataFrame({"mask": mask})
    # join indices to avoid re-reading: simplest is refilter the df we loaded
    filtered = df.filter(pl.Series(mask))
    filtered.write_parquet("comments_non_english.parquet")
