// Presentation-ready Typst document (16:9)
#set page(width: 16cm, height: 9cm, margin: 1cm)
#set heading(numbering: none)

#let accent = rgb(0x2f, 0x6f, 0xf6)
#let subtle = luma(96%)

// Title Slide
#align(center)[
  #v(1.5cm)
  #text(size: 22pt, weight: "bold")[Analyzing Public Discussions for Product Insights]
  #v(6pt)
  #text(size: 11pt, fill: gray)[Mining Reddit and Tiki for product issues, sentiment, and trends]
  #v(6pt)
  #text(size: 10pt)[From noisy threads → actionable product signals.]
  #v(6pt)
  #text(size: 9pt, fill: gray)[[Placeholder image: collage of anonymized comment snippets with callouts]]
  // #v(1.5cm)
  // #text(size: 10pt)[Team: Add names and roles here]
  // #v(4pt)
  // #text(size: 9pt, fill: gray)[Date: #datetime.today()]
]

#pagebreak()

= Problem & Value

- Which products break, why, and how often—using public discussions.
- Turn unstructured Reddit and Tiki text into actionable product signals.
- Output insights teams can ship on: issues, trends, severity, examples.

#pagebreak()

= Objectives

- Which issues? How frequent? How trending? What severity?
- Where do issues cluster (by product/subreddit/time)?
- How reliable are methods vs baselines?
- Deliver a repeatable pipeline and clear, prioritized findings.

#pagebreak()

// = Executive Summary
//
// - Battery swelling dominates r/macbookpro in Q2–Q3 (placeholder data).
// - Smart-home connectivity drops spike post-firmware X (placeholder data).
// - Headphones: left-channel crackle clusters on model Y (placeholder data).
// - [Placeholder image: multi-subreddit bar chart of top 5 issues by frequency]
//
// #pagebreak()

= Why These Platforms?

- Reddit: rich, threaded discussions; public API; strong NLP support.
- Tiki (e-commerce): structured, purchase-verified reviews; VN market signal.
- Complementary: text-rich threads vs short reviews → broader coverage.
- [Placeholder image: two-column pros/cons cards + coverage map]

#pagebreak()

= Data Collection

- *Initial:* PRAW (Python Reddit API Wrapper) for prototyping.
  - *Limitation:* ~1,000 post cap, rate limits.
- *Current (Hybrid):*
  - Reddit historical archives (Academic Torrents) to bypass API caps.
  - Tiki review dumps for cross-source validation.
  - *Result:* Broader time windows, more volume.
- [Placeholder image: timeline ribbon PRAW → Archives → Tiki]
- [Placeholder image: flowchart with rate-limit icon on PRAW; time-filter lock]

#pagebreak()


#align(center)[
  #text(size: 12pt, weight: "bold")[ = How PRAW Traverses Comments ]
]
#columns(2)[

    - Reddit returns comment trees with `View more comments` placeholders.
    - We expand lazily, traverse, and serialize—no one-click “download”.
    - Captures full depth where needed; avoids rate-limit explosions.
    // - [Placeholder image: comment tree diagram with expansion arrows]
  #colbreak()

#image("images/more-comments.png", height: 100%)
]


#pagebreak()

#align(center)[
  #text(size: 12pt, weight: "bold")[ = Alternatives Considered ]
]

#grid(
  columns: (4fr, 6fr),   // 4:6 ratio
  column-gutter: 1cm,
  [
    #strong[Pushshift.io (Pushshift API)]  
    - More powerful than PRAW, can filter posts by time  
    - Requires moderator status \ → not feasible
  ],
  [
    #image("images/pushshift.png", width: 100%)
  ]
)
#grid(
  columns: (4fr, 5fr),   // 4:6 ratio
  column-gutter: 1cm,
  [
#strong[Personal Archive]  
- Continuous collection over weeks  
- Impractical: hardware/time, can’t capture older posts
  ],
  [
    #image("images/archive.png", width: 100%)
  ]
)


#grid(
  columns: (4fr, 6fr),   // 4:6 ratio
  column-gutter: 1cm,
  [
#strong[Academic Torrents (Arctic Shift)]  
  - Downloadable historical Reddit datasets  
  - Good for history + scale
  ],
  [
    #image("images/artic-shift.png", width: 100%)
  ]
)



#pagebreak()

#align(center)[
  #text(size: 12pt, weight: "bold")[ = Subreddits Chosen ]
]
#grid(
  columns: (6fr, 4fr),   // 4:6 ratio
  column-gutter: 1cm,
  [
- A diverse mix of tech and lifestyle communities:
- r/macbookpro, r/GamingLaptops
- r/iphone, r/AppleWatch, r/Monitors, r/headphones, r/homelab, r/photography
- ...and several others covering home, audio, and PC building.
- total : `134121` posts, `1300190` comments, 2025-06-01 -> 2025-07-31. 
// - [Placeholder image: grid of subreddit badges sized by sample count]
//  with expansion arrows

  ],
  [
#image("images/subreddits.png", width: 60%)
#image("images/item_counts.png", width: 90%)
  ]
)




#pagebreak()

= EDA Highlights

- [Placeholder image: time series of comments/week by subreddit]
- [Placeholder image: length distribution (boxplot or histogram)]
- [Placeholder image: top product mentions (bar) via keyword/NER]
- Takeaways (placeholder): spikes follow launch X; r/homelab comments 2× longer.

#pagebreak()

= Preprocessing Pipeline

[data before and after]
- *Ingestion:* Ingested JSONL into typed Parquet schemas using Polars & Nushell.
- *Cleaning:*
  - Removed URLs, stripped markup, normalized whitespace.
  - Filtered for English-only content for initial analysis.
- *Modeling Choice:* Modeled each comment individually after experiments showed parent context polluted sentiment signals.
- Randomized 100 posts/sub (seeded) to reduce virality bias. (placeholder)
- [Placeholder image: before/after text snippet (URLs/emojis removed)]
- [Placeholder image: language donut (kept vs dropped)]
- [Placeholder image: schema alignment diagram JSONL → typed Parquet]

#pagebreak()

= Context Experiment (Per-Comment SA)

- Parent-context vs per-comment classification compared on small labeled set.
- Result: per-comment avoids 512-token truncation and context pollution.
- [Placeholder image: ablation bar chart (F1 with vs without parent context)]

#pagebreak()

= Sentiment Analysis (SA)

- *Approach:* Pretrained transformers over simpler baselines (VADER, TextBlob).
- *Model:* `lxyuan/distilbert-base-multilingual-cased-sentiments-student`
  - *Why:* Good multilingual support, lightweight, strong zero-shot performance.
- *Execution:* Rented GPU on `vast.ai` for large-scale inference.
- *Next Step:* Fine-tune on a domain-specific labeled dataset.
- [Placeholder image: model compare bar (VADER/TextBlob/DistilBERT) on labeled set]
- [Placeholder image: throughput/cost bar CPU vs GPU on vast.ai]
- [Placeholder image: confusion matrix or calibration curve]
- [Placeholder panel: 2–3 qualitative examples with predicted labels]

#pagebreak()

= Topic Modeling (Planned)

- *Goal:* Discover key themes and issues per subreddit.
- *Method:* Evaluate BERTopic vs. traditional methods (LDA/NMF).
- *Process:* Preprocess with domain stopwords, lemmatization.
- *Output:* Top topics, representative comments, and trend lines.
- Target: coherence c_v threshold and stable topics across subsamples. (placeholder)
- [Placeholder image: intertopic distance map (BERTopic mock)]
- [Placeholder image: top-words table for 2 sample topics]

#pagebreak()

= CLI Tool (Planned)

- A pipeline for repeatable analysis:
- `ingest`: Raw data to Parquet.
- `clean`: Filter and normalize data.
- `sentiment`: Run batch sentiment analysis.
- `topics`: Train and apply topic models.
- `report`: Aggregate results and export.

#pagebreak()

= Risks & Mitigations

- *Bias:* Sampled randomly across multiple, diverse subreddits.
- *Time Drift:* Included time slices to compare cohorts.
- *Reproducibility:* Pinned environments, config-driven runs, and stored seeds.
- *Ethics:* Used public data, followed platform ToS, aggregated results.

#pagebreak()

= Next Steps

- Finalize EDA visualizations.
- Run sentiment analysis at scale.
- Pilot and select a topic modeling approach.
- Build and demo the core CLI workflow.
- Begin labeling for fine-tuning sentiment model.

#pagebreak()

= Q & A
