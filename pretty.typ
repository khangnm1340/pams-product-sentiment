#set page(width: 16in, height: 9in, margin: 24pt)
#set heading(numbering: none)
#set par(justify: false)

// Styled "vision" for: Asset Sentiment & Topic Explorer
// Focus: clear layout, color, and simple visuals (bars/pills)

// Palette
#let slate_900 = rgb(15, 23, 42)
#let slate_700 = rgb(51, 65, 85)
#let slate_600 = rgb(71, 85, 105)
#let slate_200 = rgb(226, 232, 240)
#let slate_100 = rgb(241, 245, 249)
#let white = rgb(255, 255, 255)

#let emerald = rgb(16, 185, 129)
#let amber = rgb(245, 158, 11)
#let rose = rgb(239, 68, 68)
#let blue = rgb(59, 130, 246)

// Helpers
#let pill(label, bg: slate_100, fg: slate_700) = box(
  inset: 6pt,
  radius: 9999pt,
  fill: bg,
  stroke: none,
)[
  #text(fill: fg, weight: 600)[#label]
]

#let card(title, body) = box(
  fill: white,
  radius: 12pt,
  stroke: slate_200,
  inset: 14pt,
)[
  #text(size: 16pt, weight: 700, fill: slate_700)[#title]
  #v(8pt)
  #body
]

#let bar_abs(fillw, base: 260pt, h: 12pt, col: blue) = box(
  width: base,
  height: h,
  fill: slate_100,
  radius: 8pt,
  inset: 0pt,
)[
  #box(width: fillw, height: h, fill: col, radius: 8pt)[]
]

#let verdict_chip(v) = if v == "Positive" {
  pill("Positive", bg: rgb(236, 253, 245), fg: emerald)
} else if v == "Negative" {
  pill("Negative", bg: rgb(254, 242, 242), fg: rose)
} else {
  pill("Neutral", bg: rgb(255, 251, 235), fg: amber)
}

// Header / Hero band
#box(fill: slate_900, radius: 16pt, inset: 18pt)[
  #columns(2, gutter: 24pt)[
    [
      #text(size: 30pt, weight: 800, fill: white)[Asset Sentiment & Topic Explorer]
      #v(6pt)
      #text(fill: rgb(203, 213, 225))[A clean preview of the CLI-driven report]
      #v(12pt)
      #pill("Query: headphones", bg: rgb(51, 65, 85), fg: white) #h(8pt)
      #pill("Source: Arctic Shift", bg: rgb(51, 65, 85), fg: white) #h(8pt)
      #pill("Model: lxyuan/distilbert...", bg: rgb(51, 65, 85), fg: white)
    ]
    [
      #align(right)[
        #text(weight: 700, fill: white)[Score Legend]
        #v(6pt)
        #bar_abs(140pt, base: 140pt, col: emerald) #h(8pt) #text(fill: rgb(226, 232, 240))[Positive]
        #v(6pt)
        #bar_abs(70pt, base: 140pt, col: amber) #h(8pt) #text(fill: rgb(226, 232, 240))[Neutral]
        #v(6pt)
        #bar_abs(42pt, base: 140pt, col: rose) #h(8pt) #text(fill: rgb(226, 232, 240))[Negative]
      ]
    ]
  ]
]

#v(14pt)

// Body layout
#columns(2, gutter: 24pt)[
  [
    // Brand card with structured rows
    #let brand_row(name, avg, mentions, verdict, widthpt, col) = box(inset: 0pt)[
      #text(weight: 700, fill: slate_700)[#name] #h(8pt) #verdict_chip(verdict)
      #v(4pt)
      #bar_abs(widthpt, base: 220pt, col: col)
      #v(2pt)
      #text(size: 10pt, fill: slate_600)[avg: #avg — mentions: #mentions]
      #v(8pt)
      #box(width: 100%, height: 1pt, fill: slate_200)[]
      #v(8pt)
    ]

    #card("Brand Summary (Averaged Sentiment)", [
      #text(fill: slate_600)[Averaged scores in [-1, 1] over all mentions.]
      #v(10pt)
      #brand_row("Sony", 0.62, 1250, "Positive", 161pt, emerald)
      #brand_row("Bose", 0.48, 980, "Positive", 125pt, emerald)
      #brand_row("Apple AirPods Max", 0.15, 540, "Neutral", 150pt, amber)
      #brand_row("JBL", -0.12, 610, "Negative", 114pt, rose)
      #brand_row("Sennheiser", 0.41, 430, "Positive", 182pt, emerald)
    ])
  ]
  [
    #card("Product Drill-down: JBL Tune 760NC", [
      #pill("Overall: -0.12 Negative", bg: rgb(254, 242, 242), fg: rose) #h(8pt)
      #pill("Mentions: 610")
      #v(12pt)

      #text(weight: 700, fill: slate_700)[Top Topics]
      #v(6pt)
      // Topics with bars
      #text(fill: slate_700)[1. Audio issues — 24%]
      #bar_abs(62pt, base: 260pt, col: rose)
      #v(6pt)

      #text(fill: slate_700)[2. Comfort — 18%]
      #bar_abs(47pt, base: 260pt, col: amber)
      #v(6pt)

      #text(fill: slate_700)[3. Battery — 15%]
      #bar_abs(39pt, base: 260pt, col: blue)
      #v(6pt)

      #text(fill: slate_700)[4. Connectivity — 13%]
      #bar_abs(34pt, base: 260pt, col: blue)
      #v(6pt)

      #text(fill: slate_700)[5. ANC performance — 12%]
      #bar_abs(31pt, base: 260pt, col: amber)

      #v(12pt)
      #text(weight: 700, fill: slate_700)[Bad Points]
      #v(4pt)
      #text(fill: slate_600)[• “Audio crackles at higher volume during calls.”]
      #text(fill: slate_600)[• “Bluetooth drops occasionally when walking.”]
      #text(fill: slate_600)[• “ANC is okay but struggles on flights.”]

      #v(10pt)
      #text(weight: 700, fill: slate_700)[Good Points]
      #v(4pt)
      #text(fill: slate_600)[• “Battery lasts all week with daily commute.”]
      #text(fill: slate_600)[• “Lightweight and comfortable for long sessions.”]
      #text(fill: slate_600)[• “Quick pair works reliably with Android.”]
    ])
  ]
]

#v(12pt)

// Footer
#align(center)[
  #text(size: 10pt, fill: slate_600)[CLI flow: `pams-sentiment headphones` → select brand → `--brand JBL`]
]
