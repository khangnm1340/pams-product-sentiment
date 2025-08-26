
Awesome start. Here’s a tight upgrade plan (no code) with exactly what to add, cut, and show—plus concrete image/figure ideas for each slide.

# Big structural tweaks (story first)

* Open with the **problem & value** in one slide: “Which products break, why, and how often—using public discussions.”
* Add a **one-slide executive summary** with 3–5 headline findings (even if provisional): e.g., “Battery swelling dominates r/macbookpro Q2–Q3; smart-home ‘connectivity drop’ spikes after firmware X; headphones: ‘left channel crackle’ clusters on model Y.”
* For every method choice, add an **evidence slide** (mini ablation/metric) that justifies it (e.g., random sampling > top posts; per-comment SA > hierarchical).
* Keep a **single through-line example** (one product/thread) that reappears to humanize the data.
* Move “Risks & Ethics” **before** “Next Steps” to show you’ve de-risked the plan.
* End with a **decision slide**: what you’ll ship next week + what help you need (labeling hours, GPU budget, subreddit additions).

# Slide-by-slide upgrade plan (with visuals to show)

1. **Title (keep)**

* Visual: subtle collage of anonymized comment snippets (blur names), with 2–3 yellow callouts (e.g., “swollen battery”, “coil whine”).
* Add a 1-line promise: “From noisy threads → actionable product signals.”

2. **Objectives (tighten)**

* Swap bullets to questions: “Which issues? How frequent? How trending? What severity?”
* Visual: small **Sankey** thumbnail: Sources → Processing → Metrics → Insights.

3. **Executive Summary (new)**

* 3–5 takeaways + 1 chart.
* Visual: **multi-subreddit bar**: top 5 issues by frequency (placeholder).

4. **Why Reddit (+Tiki)** (merge your current “Why These Platforms” & add tradeoffs)

* Visual: **two-column pros/cons** cards + **coverage map** of markets (Tiki ≈ VN signal).
* Add a callout: “Text-rich threads vs. short reviews → complementary.”

5. **Data Collection (Initial vs Now)** (tight)

* Visual A: **timeline ribbon** of methods (PRAW → Archives → Tiki).
* Visual B: **flowchart** with rate-limit icons on PRAW; “time filter” lock on Pushshift.

6. **How PRAW Traverses Comments (clarify mechanism)**

* Visual: **comment tree diagram** with `MoreComments` placeholders and arrows showing expansion; a small “lazy fetch” icon.
* Side note: “Objects → manual traversal → serialization (not one click ‘download’).”

7. **Alternatives Considered (decision evidence)**

* Visual: **scorecard table** (Access, Time filtering, Scale, Feasibility) for Pushshift / Academic Torrents / Personal Archive, with one “Chosen for: history + scale” badge.

8. **Subreddits Chosen (show coverage)**

* Visual: **grid of subreddit badges** sized by sample counts, or **treemap** by comment volume.
* Add one example line under the grid: “15 subs, \~N posts, \~M comments, YYYY–YYYY.”

9. **EDA Highlights (fill with 3 quick wins)**

* Visuals (pick two):

  * **Time series**: comments/week by subreddit.
  * **Length distribution** (boxplot or histogram).
  * **Top product mentions** (bar) from simple keyword/NER.
* One sentence per chart: “Spikes follow launch X”, “r/homelab comments are 2× longer.”

10. **Preprocessing Pipeline (make it tangible)**

* Visual A: **before/after text snippet** (URLs/emojis removed).
* Visual B: **language donut** (kept vs. dropped).
* Visual C: **schema alignment** mini-diagram (JSONL → typed Parquet; bad column quarantined).
* One callout: “Randomize 100 posts/sub (seeded) to reduce virality bias.”

11. **Context Experiment (why per-comment SA)**

* Visual: **ablation bar**: F1 (with vs. without parent context).
* Tiny schematic: 512-token truncation → “context pollution” icon.

12. **Sentiment Analysis (model choice by evidence)**

* Visuals (choose two):

  * **Model compare bar** (VADER/TextBlob/DistilBERT) on a small labeled set.
  * **Throughput/cost bar** (CPU vs. GPU on vast.ai) with \$\$ and mins.
  * **Calibration curve** or **confusion matrix** (readable numbers only).
* Add 2–3 **qualitative examples** panel: text + predicted label + why.

13. **Topic Modeling (planned but concrete)**

* Visual: **intertopic distance map** (BERTopic) mock + **top-words table** for 2 topics.
* Add a “coherence c\_v target” badge and a **stability across subsamples** arrow.

14. **CLI — Demo storyboard (no live code)**

* Visual: **three frames** (like comic panels):

  1. `ingest` → shows schema check icon
  2. `sentiment` → progress bar & GPU badge
  3. `report` → exports Parquet + charts thumbnail
* Include a **one-line usage promise**: “One command per stage; idempotent; resumable.”

15. **Risks & Mitigations**

* Visual: **matrix** (Risk × Mitigation) with severity color.
* Include: subreddit culture bias, time drift, language scope, ToS/PII, schema drift.

16. **Next Steps / Ask**

* Visual: **mini-Gantt** for 2–4 weeks.
* Bullets: labeling plan (size & IAA), topic model pick criteria, CLI polish, final EDA pack.

17. **Appendix (backup)**

* Visuals: hyperparams table, hardware/env, exact sample counts, subreddit list, ethics notes.

# Image/figure checklist (what to actually show)

* Anonymized **thread screenshot** (highlight key phrases).
* **Data pipeline diagram** (sources → ETL → models → outputs).
* **Comment tree** with `MoreComments` expansion.
* **Treemap** of subreddit coverage.
* **Time series** of volume; **length histogram**.
* **Before/after text snippet** (preprocessing).
* **Language donut**; **sampling schematic** (top vs random).
* **Ablation bar** (context vs no-context).
* **Model compare** bar; **throughput/cost** bar; **confusion matrix** or **calibration**.
* **Intertopic map** + **top-words table**.
* **CLI storyboard** (3 frames).
* **Risk matrix**; **mini-Gantt**.

# Content you should quantify (slot numbers in)

* Time window(s), #subreddits, #posts, #comments, #unique users.
* Drop rates: non-English %, URL-only/short texts %.
* Sampling seed & resulting counts per subreddit.
* SA metrics (F1/accuracy) on a **tiny labeled** validation set.
* Inference throughput (comments/sec) and **\$ cost** CPU vs GPU.
* Topic modeling coherence and #topics chosen.

# Design & delivery polish

* Keep 3–5 bullets max per slide; one **chart per slide**.
* Use **consistent callouts** (green = decision, amber = risk, blue = method).
* Put **takeaway captions** under every chart (“So what?” in 8–10 words).
* Title slides as **claims** not nouns: “Random sampling beats top-posts by 14% F1.”
* Font size big: titles ≥ 28pt, body ≥ 16pt; generous whitespace.
* Color-blind safe palette; avoid heavy reds/greens together.
* For a 10-min talk: 12–14 content slides + 3 backup; \~40–50 seconds per slide.

# Talk track prompts (notes to self)

* Open with the **one concrete user pain** you discovered.
* For each method slide, say **why this choice wins** (1 sentence) + show **evidence**.
* Close with **what you’ll ship next week** and **what help you need**.

If you want, I can turn this into a slide-by-slide checklist you can paste next to your Typst file while you build.
