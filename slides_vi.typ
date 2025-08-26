// Typst presentation slides (16:9) - Vietnamese
#set page(width: 16cm, height: 9cm, margin: 1cm)
#set heading(numbering: none)

#let accent = rgb(0x2f, 0x6f, 0xf6)
#let subtle = luma(96%)

// Slide 1: Title
#align(center)[
  #v(1.5cm)
  #text(size: 22pt, weight: "bold")[Phân tích thảo luận công khai để tìm hiểu sâu về sản phẩm]
  #v(6pt)
  #text(size: 11pt, fill: gray)[Khai thác Reddit và Tiki để tìm các vấn đề, tình cảm và xu hướng của sản phẩm]
  #v(6pt)
  #text(size: 10pt)[Từ các cuộc thảo luận ồn ào → tín hiệu sản phẩm có thể hành động.]
]

#pagebreak()

// Slide 2: Problem & Value
= Vấn đề & Giá trị
- Sản phẩm nào bị hỏng, tại sao và tần suất—sử dụng các cuộc thảo luận công khai.
- Biến văn bản Reddit và Tiki phi cấu trúc thành các tín hiệu sản phẩm có thể hành động.
- Cung cấp thông tin chi tiết mà các nhóm có thể sử dụng: vấn đề, xu hướng, mức độ nghiêm trọng, ví dụ.

#pagebreak()

// Slide 3: Objectives
= Mục tiêu
- Vấn đề nào? Tần suất? Xu hướng? Mức độ nghiêm trọng?
- Các vấn đề tập trung ở đâu (theo sản phẩm/subreddit/thời gian)?
- Các phương pháp đáng tin cậy như thế nào so với các đường cơ sở?
- Cung cấp một quy trình có thể lặp lại và các phát hiện rõ ràng, được ưu tiên.

#pagebreak()

// Slide 4: Why These Platforms?
= Tại sao lại là những nền tảng này?
- Reddit: thảo luận theo chuỗi phong phú; API công khai; hỗ trợ NLP mạnh mẽ.
- Tiki (thương mại điện tử): đánh giá có cấu trúc, được xác minh mua hàng; tín hiệu thị trường Việt Nam.
- Bổ sung cho nhau: các chuỗi giàu văn bản so với các bài đánh giá ngắn → phạm vi bao phủ rộng hơn.

#pagebreak()

// Slide 5: Data Collection
= Thu thập dữ liệu
- *Ban đầu:* PRAW (Python Reddit API Wrapper) để tạo mẫu.
  - *Hạn chế:* Giới hạn ~1.000 bài đăng, giới hạn tốc độ.
- *Hiện tại (Kết hợp):*
  - Kho lưu trữ lịch sử Reddit (Academic Torrents) để bỏ qua giới hạn API.
  - Dữ liệu đánh giá Tiki để xác thực chéo nguồn.
  - *Kết quả:* Cửa sổ thời gian rộng hơn, khối lượng lớn hơn.

#pagebreak()

// Slide 6: How PRAW Traverses Comments
#align(center)[#text(size: 12pt, weight: "bold")[ = Cách PRAW duyệt qua các bình luận ]]
#columns(2)[
    - Reddit trả về cây bình luận với các trình giữ chỗ `Xem thêm bình luận`.
    - Chúng tôi mở rộng một cách lười biếng, duyệt qua và tuần tự hóa—không có “tải xuống” bằng một cú nhấp chuột.
    - Ghi lại toàn bộ chiều sâu khi cần thiết; tránh bùng nổ giới hạn tốc độ.
  #colbreak()
  #image("images/more-comments.png", height: 100%)
]

#pagebreak()

// Slide 7: Alternatives Considered
#align(center)[#text(size: 12pt, weight: "bold")[ = Các phương án thay thế đã được xem xét ]]
#grid(
  columns: (4fr, 6fr),
  column-gutter: 1cm,
  [#strong[Pushshift.io (Pushshift API)]],
  [#image("images/pushshift.png", width: 100%)]
)
#grid(
  columns: (4fr, 5fr),
  column-gutter: 1cm,
  [#strong[Lưu trữ cá nhân]],
  [#image("images/archive.png", width: 100%)]
)
#grid(
  columns: (4fr, 6fr),
  column-gutter: 1cm,
  [#strong[Academic Torrents (Arctic Shift)]],
  [#image("images/artic-shift.png", width: 100%)]
)

#pagebreak()

// Slide 8: Subreddits Chosen
#align(center)[#text(size: 12pt, weight: "bold")[ = Các subreddit đã chọn ]]
#grid(
  columns: (6fr, 4fr),
  column-gutter: 1cm,
  [
    - Một sự kết hợp đa dạng của các cộng đồng công nghệ và lối sống:
    - r/macbookpro, r/GamingLaptops, r/iphone, r/AppleWatch, ...
    - tổng cộng : `134121` bài đăng, `1300190` bình luận.
  ],
  [
    #image("images/subreddits.png", width: 60%)
    #image("images/item_counts.png", width: 90%)
  ]
)

#pagebreak()

// Slide 9: EDA Highlights
= Điểm nổi bật của EDA
- [Hình ảnh giữ chỗ: chuỗi thời gian của bình luận/tuần theo subreddit]
- [Hình ảnh giữ chỗ: phân phối độ dài (biểu đồ hộp hoặc biểu đồ tần suất)]
- [Hình ảnh giữ chỗ: các đề cập sản phẩm hàng đầu (thanh) qua từ khóa/NER]
- Điểm chính (giữ chỗ): số lượng tăng đột biến sau khi ra mắt X; bình luận trên r/homelab dài gấp 2 lần.

#pagebreak()

// Slide 10: Preprocessing Pipeline
= Quy trình tiền xử lý
- *Nạp dữ liệu:* Nạp JSONL vào các lược đồ Parquet đã nhập bằng Polars & Nushell.
- *Làm sạch:* Xóa URL, loại bỏ đánh dấu, chuẩn hóa khoảng trắng.
- *Lựa chọn mô hình hóa:* Lập mô hình từng bình luận riêng lẻ.

#pagebreak()

// Slide 11: Context Experiment
= Thử nghiệm ngữ cảnh (SA mỗi bình luận)
- So sánh phân loại theo ngữ cảnh gốc và mỗi bình luận trên một tập dữ liệu nhỏ được gắn nhãn.
- Kết quả: mỗi bình luận tránh được việc cắt ngắn 512 mã thông báo và ô nhiễm ngữ cảnh.

#pagebreak()

// Slide 12: Sentiment Analysis (SA)
= Phân tích tình cảm (SA)
- *Phương pháp:* Các máy biến áp được đào tạo trước.
- *Mô hình:* `lxyuan/distilbert-base-multilingual-cased-sentiments-student`
- *Thực thi:* Thuê GPU trên `vast.ai`.
- *Bước tiếp theo:* Tinh chỉnh trên một tập dữ liệu được gắn nhãn.

#pagebreak()

// Slide 13: Topic Modeling (Planned)
= Lập mô hình chủ đề (Đã lên kế hoạch)
- *Mục tiêu:* Khám phá các chủ đề và vấn đề chính trên mỗi subreddit.
- *Phương pháp:* Đánh giá BERTopic so với các phương pháp truyền thống.
- *Quy trình:* Tiền xử lý với các từ dừng miền, bổ sung.
- *Đầu ra:* Các chủ đề hàng đầu, bình luận đại diện và đường xu hướng.

#pagebreak()

// Slide 14: CLI Tool (Planned)
= Công cụ CLI (Đã lên kế hoạch)
- Một quy trình để phân tích có thể lặp lại:
- `ingest`: Dữ liệu thô sang Parquet.
- `clean`: Lọc và chuẩn hóa dữ liệu.
- `sentiment`: Chạy phân tích tình cảm hàng loạt.
- `topics`: Đào tạo và áp dụng các mô hình chủ đề.
- `report`: Tổng hợp kết quả và xuất.

#pagebreak()

// Slide 15: Risks & Mitigations
= Rủi ro & Giảm thiểu
- *Sai lệch:* Lấy mẫu ngẫu nhiên trên nhiều subreddit đa dạng.
- *Trôi dạt theo thời gian:* Bao gồm các lát thời gian để so sánh các nhóm.
- *Khả năng tái tạo:* Môi trường được ghim, chạy theo cấu hình.
- *Đạo đức:* Sử dụng dữ liệu công khai, tuân theo Điều khoản dịch vụ.

#pagebreak()

// Slide 16: Next Steps
= Các bước tiếp theo
- Hoàn thiện trực quan hóa EDA.
- Chạy phân tích tình cảm ở quy mô lớn.
- Thử nghiệm và chọn một phương pháp lập mô hình chủ đề.
- Xây dựng và trình diễn quy trình làm việc CLI cốt lõi.
- Bắt đầu gắn nhãn để tinh chỉnh mô hình tình cảm.

#pagebreak()

// Slide 17: Q&A
= Hỏi & Đáp
