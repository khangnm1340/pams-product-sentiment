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
  #v(1.5cm)
  #text(size: 10pt)[Team: Add names and roles here]
  // #v(4pt)
  // #text(size: 9pt, fill: gray)[Date: #datetime.today()]
]

#pagebreak()

= Objectives

- *Goal:* Mine Reddit & Tiki for product insights.
- *Identify:* Common issues, pros/cons, and sentiment for consumer products.
- *Deliver:* A CLI tool, datasets, and analysis.

#pagebreak()

= Why These Platforms?

- *Reddit:*
  - Rich, threaded discussions.
  - Public API & strong NLP support.
- *Tiki (E-commerce):*
  - Structured, purchase-verified reviews.
  - Complements Reddit with Vietnam market signal.

#pagebreak()

= Data Collection

- *Initial:* PRAW (Python Reddit API Wrapper) for prototyping.
  - *Limitation:* ~1,000 post cap, rate limits.
- *Current (Hybrid):*
  - Reddit historical archives (Academic Torrents) to bypass API caps.
  - Tiki review dumps for cross-source validation.
  - *Result:* Broader time windows, more volume.

#pagebreak()

= Subreddits Chosen

- A diverse mix of tech and lifestyle communities:
- r/macbookpro, r/GamingLaptops
- r/iphone, r/AppleWatch, r/Monitors
- r/headphones, r/homelab, r/photography
- ...and several others covering home, audio, and PC building.

#pagebreak()

= Preprocessing Pipeline

- *Ingestion:* Ingested JSONL into typed Parquet schemas using Polars & Nushell.
- *Cleaning:*
  - Removed URLs, stripped markup, normalized whitespace.
  - Filtered for English-only content for initial analysis.
- *Modeling Choice:* Modeled each comment individually after experiments showed parent context polluted sentiment signals.

#pagebreak()

= Sentiment Analysis (SA)

- *Approach:* Pretrained transformers over simpler baselines (VADER, TextBlob).
- *Model:* `lxyuan/distilbert-base-multilingual-cased-sentiments-student`
  - *Why:* Good multilingual support, lightweight, strong zero-shot performance.
- *Execution:* Rented GPU on `vast.ai` for large-scale inference.
- *Next Step:* Fine-tune on a domain-specific labeled dataset.

#pagebreak()

= Topic Modeling (Planned)

- *Goal:* Discover key themes and issues per subreddit.
- *Method:* Evaluate BERTopic vs. traditional methods (LDA/NMF).
- *Process:* Preprocess with domain stopwords, lemmatization.
- *Output:* Top topics, representative comments, and trend lines.

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
