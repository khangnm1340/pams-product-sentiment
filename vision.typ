#set page(width: 16in, height: 9in, margin: 24pt)
#set heading(numbering: none)

// Vision mockup for: Asset Sentiment & Topic Explorer (CLI-backed)
// Functional-first: simple, readable layout with sample data

= Asset Sentiment & Topic Explorer

This page is a functional mockup of the final CLI-driven report. It shows:
- Query input, data source, and model references
- Brand-level sentiment summary (averaged scores over mentions)
- Optional drill-down for a selected product with topics and points

== Query & Setup

Query: `headphones`

Data Source: Arctic Shift (public discussions)

Sentiment Model: `lxyuan/distilbert-base-multilingual-cased-sentiments-student`

Scoring: average of [-1, 1] per brand based on all matching comments.

== Brand Summary (Averaged Sentiment)

The following list approximates the CLI output for the top brands detected in the dataset for the query.

- Sony — avg: 0.62 — mentions: 1,250 — verdict: Positive
- Bose — avg: 0.48 — mentions: 980 — verdict: Positive
- Apple AirPods Max — avg: 0.15 — mentions: 540 — verdict: Neutral
- JBL — avg: -0.12 — mentions: 610 — verdict: Negative
- Sennheiser — avg: 0.41 — mentions: 430 — verdict: Positive

Tip: In the CLI, the user would select any brand to see product-level details and topics.

== Product Drill-down (Example)

Selected: JBL Tune 760NC

- Overall Sentiment: -0.12 — Negative
- Mentions: 610 (subset of brand mentions matching product variant)

Top Topics (topic modeling on matched comments):

1. Audio issues — 24%
2. Comfort — 18%
3. Battery — 15%
4. Connectivity — 13%
5. ANC performance — 12%

Bad Points (sample comment snippets):

- “Audio crackles at higher volume during calls.”
- “Bluetooth drops occasionally when walking.”
- “ANC is okay but struggles on flights.”

Good Points (sample comment snippets):

- “Battery lasts all week with daily commute.”
- “Lightweight and comfortable for long sessions.”
- “Quick pair works reliably with Android.”

== Notes

- CLI flow: `pams-sentiment headphones` shows brand table; `--brand JBL` drills down.
- Future additions: sorting, filters, export (CSV/JSON), and richer visuals (bars/sparks).

