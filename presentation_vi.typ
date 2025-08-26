// Bản trình chiếu Typst (16:9)
#set page(width: 16cm, height: 9cm, margin: 1cm)
#set heading(numbering: none)

#let accent = rgb(0x2f, 0x6f, 0xf6)
#let subtle = luma(96%)
#set text(size: 10pt)

// Trang tiêu đề
#align(center)[
  #v(1.5cm)
  #text(size: 20pt, weight: "bold")[Phân tích thảo luận công khai để khai phá hiểu biết sản phẩm]
  #v(6pt)
  #text(size: 10pt, fill: gray)[Khai thác Reddit và Tiki về lỗi sản phẩm, cảm xúc và xu hướng]
  #v(6pt)
  #text(size: 9pt)[Từ chuỗi thảo luận ồn ào → tín hiệu sản phẩm có thể hành động.]
  #v(6pt)
  #text(size: 8pt, fill: gray)[[TẦM NHÌN]]
]

#pagebreak()

= Vấn đề & Giá trị

- Sản phẩm nào hỏng, vì sao và tần suất bao nhiêu — dựa trên thảo luận công khai.
- Biến văn bản Reddit và Tiki phi cấu trúc thành tín hiệu sản phẩm hữu ích.
- Xuất ra insight có thể triển khai: lỗi, xu hướng, mức độ nghiêm trọng, ví dụ.


= Mục tiêu

- Lỗi nào? Tần suất? Xu hướng? Mức độ nghiêm trọng?
- Lỗi tập trung ở đâu (theo sản phẩm/subreddit/thời gian)?
// - Độ tin cậy của phương pháp so với baseline?
- Bàn giao pipeline lặp lại được và phát hiện rõ ràng, có ưu tiên.

#pagebreak()

// = Tóm tắt điều hành
// - Phồng pin chiếm ưu thế ở r/macbookpro trong Q2–Q3 (dữ liệu placeholder).
// - Rớt kết nối smart-home tăng đột biến sau firmware X (placeholder).
// - Tai nghe: rè kênh trái cụm ở model Y (placeholder).
// - [Hình minh họa: biểu đồ cột nhiều subreddit cho top 5 lỗi theo tần suất]

= Vì Sao Các Nền Tảng Này?

- Reddit: thảo luận theo chủ đề phong phú; API công khai; hỗ trợ NLP tốt.
- Tiki (TMĐT): đánh giá có cấu trúc, xác thực mua hàng; tín hiệu thị trường VN.
- Bổ trợ: thread giàu chữ vs đánh giá ngắn → độ phủ rộng hơn.
// - [Hình minh họa: hai cột ưu/nhược + bản đồ phủ]
= So Sánh Nguồn Dữ Liệu

#table(
  columns: (auto, 5cm, 7cm),
  align: (left, top, top),
  stroke: 0.5pt + gray,
  inset: 6pt,

  // Hàng tiêu đề
  [*Nền tảng*], [*Ưu điểm*], [*Nhược điểm*],

  // Reddit
  [Reddit],
  [
    - API công khai (dễ truy cập) \
    - Thảo luận văn bản phong phú \
    - Hỗ trợ NLP tiếng Anh tốt \
    - Cộng đồng theo chủ đề "subreddits"
  ],
  [
    - Nhiễu và lệch chủ đề \
    - Dữ liệu tiếng Việt hạn chế \
    - Hạn mức/giới hạn sử dụng API
  ],

  // Facebook
  [Facebook],
  [
    - Lượng người dùng lớn tại Việt Nam \
    - Nhóm và cộng đồng hoạt động \
    - Chủ đề đa dạng
  ],
  [
    - Nhiều bot/tài khoản rác \
    - Giới hạn API \
    - Khó thu thập dữ liệu sạch \
    - Hỗ trợ từ thư viện NLP tiếng Anh yếu
  ],

  // TikTok
  [TikTok],
  [
    - Rất phổ biến với người trẻ \
    - Nắm bắt xu hướng/meme tốt
  ],
  [
    - Chủ yếu nội dung media (video, ảnh) \
    - Không có API chính thức \
    - Thiếu cấu trúc nhóm/cộng đồng \
    - Thu thập chậm (phải parse HTML) \
    - Khó trích xuất văn bản liên quan
  ]
)

#pagebreak()

= Thu Thập Dữ Liệu

- Ban đầu: PRAW (Python Reddit API Wrapper) để thử nghiệm nhanh.
  - Hạn chế: giới hạn ~1.000 bài, rate limit.
- Hiện tại (lai):
  - Kho dữ liệu lịch sử Reddit (Academic Torrents) để vượt giới hạn API.
  - Dump đánh giá Tiki để đối chiếu chéo nguồn.
  - Kết quả: cửa sổ thời gian rộng hơn, khối lượng lớn hơn.
// - [Hình: timeline PRAW → Archives → Tiki]
// - [Hình: lưu đồ với biểu tượng rate-limit ở PRAW]

#pagebreak()

#align(center)[
  #text(size: 11pt, weight: "bold")[ = PRAW duyệt cây bình luận như thế nào ]
]
#columns(2)[

    - Reddit trả về cây bình luận với chỗ trống `View more comments`.
    - Mở rộng lười, duyệt và tuần tự hóa — không có “tải xuống” một cú bấm.
    - Bắt toàn bộ độ sâu khi cần; tránh bùng nổ rate limit.
    // - [Hình: sơ đồ cây bình luận với mũi tên mở rộng]
  #colbreak()

#image("images/more-comments.png", height: 100%)
]


#pagebreak()

#align(center)[
  #text(size: 11pt, weight: "bold")[ = Phương Án Thay Thế Đã Xem Xét ]
]

#grid(
  columns: (4fr, 6fr),   // tỉ lệ 4:6
  column-gutter: 1cm,
  [
    #strong[Pushshift.io (Pushshift API)]  
    - Mạnh hơn PRAW, có thể lọc bài theo thời gian  
    - Yêu cầu quyền moderator \ → không khả thi
  ],
  [
    #image("images/pushshift.png", width: 100%)
  ]
)
#grid(
  columns: (4fr, 5fr),   // tỉ lệ 4:6
  column-gutter: 1cm,
  [
#strong[Lưu Trữ Cá Nhân]  
- Thu thập liên tục trong nhiều tuần  
- Bất khả thi: phần cứng/thời gian, không lấy được bài cũ
  ],
  [
    #image("images/archive.png", width: 100%)
  ]
)


#grid(
  columns: (4fr, 6fr),   // tỉ lệ 4:6
  column-gutter: 1cm,
  [
#strong[Academic Torrents (Arctic Shift)]  
  - Bộ dữ liệu Reddit lịch sử có thể tải về  
  - Tốt cho lịch sử + quy mô
  ],
  [
    #image("images/artic-shift.png", width: 100%)
  ]
)



#pagebreak()

#align(center)[
  #text(size: 11pt, weight: "bold")[ = Subreddit Đã Chọn ]
]
#grid(
  columns: (6fr, 4fr),   // tỉ lệ 6:4
  column-gutter: 1cm,
  [
- Tổ hợp đa dạng các cộng đồng công nghệ và đời sống:
- r/macbookpro, r/GamingLaptops
- r/iphone, r/AppleWatch, r/Monitors, r/headphones, r/homelab, r/photography
- ...và vài subreddit khác về gia đình, âm thanh, và lắp ráp PC.
- tổng: `134121` bài viết, `1300190` bình luận, 2025-06-01 → 2025-07-31.
// - [Hình: lưới huy hiệu subreddit tỷ lệ theo số mẫu]

  ],
  [
#image("images/subreddits.png", width: 60%)
#image("images/item_counts.png", width: 90%)
  ]
)




#pagebreak()

#align(center)[
  #text(size: 11pt, weight: "bold")[ = Tiki ]
]

#image("images/tiki.png", width: 80%)

#pagebreak()

= EDA Nổi Bật

- [Hình minh họa: chuỗi thời gian số bình luận/tuần theo subreddit]
- [Hình minh họa: phân bố độ dài (boxplot/histogram)]
- [Hình minh họa: sản phẩm được nhắc nhiều (cột) qua từ khóa/NER]
- Nhận xét (placeholder): đỉnh sau ra mắt X; r/homelab dài gấp 2×.

#pagebreak()

= Quy Trình Tiền Xử Lý
\

// [dữ liệu trước và sau]
#let accent = rgb(0x2f, 0x6f, 0xf6)
#let ok = rgb(0x17, 0x9e, 0x63)
#let subtle = luma(96%)

// = Nạp liệu
#text(size: 9pt, fill: gray)[Chuyển 32 JSONL → 2 Parquet (Nushell + Polars); giữ tối đa các cột có ý nghĩa.]

#v(6pt)

#grid(
  columns: (4fr, 1fr, 4fr),
  column-gutter: 14pt,
  [
    #box(fill: subtle, stroke: .6pt, radius: 10pt, inset: 10pt)[
      #text(weight: "bold")[Trước]
      #v(4pt)
      Bài viết: #strong[106] cột \
      Bình luận: #strong[69] cột
    ]
  ],
[  // ô giữa: canh giữa cả hai trục
    #align(center + horizon)[
      #text(size: 16pt, weight: "bold", fill: accent)[]
    ]
  ],
  [
    #box(
  fill: color.mix((ok, 15%), (white, 85%)),
  stroke: (paint: ok, thickness: .6pt),
  radius: 10pt,
  inset: 10pt,
  )[
      #text(weight: "bold", fill: ok)[Sau]
      #v(4pt)
      Bài viết: #strong[28] cột \
      Bình luận: #strong[17] cột
    ]
  ],
)
- Làm sạch:
  - Loại bỏ URL.
  - Lọc chỉ tiếng Anh cho phân tích ban đầu. (chỉ khoảng 5 nghìn bình luận trong 1,3 triệu, nhưng cân nhắc giữ vì mô hình đa ngôn ngữ)
// - Lựa chọn mô hình: mô hình hóa từng bình luận sau khi thử nghiệm cho thấy ngữ cảnh cha làm nhiễu tín hiệu cảm xúc.
- Top 30 + 20 bài ngẫu nhiên mỗi sub (có seed) để giảm thiên lệch lan truyền. (placeholder)
// - [Hình: trước/sau đoạn văn bản (bỏ URL/emoji)]
// - [Hình: donut ngôn ngữ (giữ vs loại)]
// - [Hình: căn chỉnh schema JSONL → Parquet có kiểu]

#image("images/data_for_ML.png", width: 60%)

#pagebreak()

= Thử Nghiệm Ngữ Cảnh (SA Theo Bình Luận)

- So sánh phân loại có ngữ cảnh cha vs theo-bình-luận trên tập nhãn nhỏ.
- Kết quả: theo bình luận tránh cắt 512 token và giảm nhiễu ngữ cảnh.
contextualized_hierarchical_output.json: minh họa bình luận kèm ngữ cảnh cây của nó.
// - [Hình: ablation (F1 có vs không ngữ cảnh cha)]
#columns(2)[
#image("images/contextualized_comment_1.png", width: 100%)
  #colbreak()
#image("images/contextualized_comment_2.png", width: 100%)
]

#pagebreak()

= Phân Tích Cảm Xúc (SA)

- Cách tiếp cận: Transformer tiền huấn luyện thay vì baseline đơn giản (VADER, TextBlob).
- Mô hình: `lxyuan/distilbert-base-multilingual-cased-sentiments-student`
  - Vì sao: hỗ trợ đa ngôn ngữ tốt, nhẹ, hiệu năng zero-shot mạnh.
- Thực thi: thuê GPU trên `vast.ai` để suy luận quy mô lớn.
- Bước tiếp theo: fine-tune trên tập nhãn theo miền.
// - [Hình: so sánh mô hình (VADER/TextBlob/DistilBERT) trên tập nhãn]
// - [Hình: throughput/chi phí CPU vs GPU trên vast.ai]

#columns(2)[
#image("images/sample_of_model.png", width: 95%)
  #colbreak()

#image("images/vast_ai.png", width: 100%)

]
// - [Hình: ma trận nhầm lẫn hoặc đường chuẩn hóa]
// - [Bảng: 2–3 ví dụ định tính với nhãn dự đoán]

#pagebreak()

= Mô Hình Chủ Đề (Dự Kiến)

- Mục tiêu: khám phá chủ đề và lỗi chính theo subreddit.
- Phương pháp: đánh giá BERTopic so với LDA/NMF truyền thống.
- Quy trình: tiền xử lý với stopword theo miền, lemmatization.
- Đầu ra: chủ đề top, bình luận tiêu biểu và đường xu hướng.
- Mục tiêu: ngưỡng coherence c_v và chủ đề ổn định qua mẫu con. (placeholder)
- [Hình: bản đồ khoảng cách chủ đề (BERTopic mock)]
- [Hình: bảng top từ cho 2 chủ đề mẫu]

#pagebreak()

= Công Cụ CLI (Dự Kiến)

- Pipeline cho phân tích lặp lại:
- `ingest`: từ dữ liệu thô sang Parquet.
- `clean`: lọc và chuẩn hóa dữ liệu.
- `sentiment`: chạy phân tích cảm xúc hàng loạt.
- `topics`: huấn luyện và áp dụng mô hình chủ đề.
- `report`: tổng hợp kết quả và xuất.

#pagebreak()

= Rủi Ro & Giảm Thiểu

- Thiên lệch: lấy mẫu ngẫu nhiên trên nhiều subreddit đa dạng.
- Trôi thời gian: bao gồm các lát thời gian để so sánh cohort.
- Tái lập: ghim môi trường, chạy theo cấu hình, lưu seed.
- Đạo đức: dùng dữ liệu công khai, tuân thủ ToS, kết quả đã tổng hợp.

#pagebreak()

= Bước Tiếp Theo

- Hoàn thiện trực quan hóa EDA.
- Chạy phân tích cảm xúc ở quy mô lớn.
- Thử nghiệm và chọn phương pháp mô hình chủ đề.
- Xây và demo workflow CLI cốt lõi.
- Bắt đầu gán nhãn để fine-tune mô hình cảm xúc.

#pagebreak()

= Hỏi & Đáp
