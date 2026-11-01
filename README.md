# On-demand Parcel Delivery System — Assignment 2 Starter

Bộ khung Flask + MySQL dành cho Bài tập lớn 2 môn Cơ sở dữ liệu. Bộ khung này được dựng lại từ ứng dụng Admin quản lý Shipper ban đầu, giữ cấu trúc màn hình và chia tầng cơ bản, nhưng **cố ý chưa cài đặt nghiệp vụ SQL/Python thuộc yêu cầu chấm điểm**.

## 1. Chạy giao diện căn bản

Bạn có thể mở ứng dụng và truy cập các màn hình ngay cả khi chưa cài MySQL hoặc chưa viết xong SQL.

### Yêu cầu

- Python 3.10+
- Trình duyệt web
- MySQL 8.0.16+ chỉ cần khi bắt đầu kết nối và kiểm thử database

### Windows — PowerShell

Mở terminal tại thư mục gốc của project (cùng cấp với README.md):

```powershell
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
python app/app.py
```

Nếu PowerShell không cho phép kích hoạt virtual environment, dùng Command Prompt:

```cmd
py -3 -m venv .venv
.venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt
python app\app.py
```

### macOS / Linux

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
python app/app.py
```

Mở trình duyệt tại:

<http://127.0.0.1:5000>

Trang chủ tự chuyển đến `/shippers`.

### Các màn hình có sẵn

| URL | Mục A2 | Mục đích |
|---|---|---|
| `/shippers` | 3.1 + 3.2 | Một màn hình khung cho thêm, xem danh sách, sửa trực tiếp và xóa Shipper; có tìm kiếm, lọc, sắp xếp |
| `/reports` | 3.3 | Form khung để gọi query procedure thứ hai hoặc một function và hiển thị kết quả |

**Lưu ý:** hiện tại các màn hình chỉ là giao diện khung. Khi bấm các thao tác dữ liệu, app sẽ hiển thị thông báo rằng phần tương ứng chưa được cài đặt; app không bị crash.

## 2. Cấu trúc thư mục

```text
parcel-delivery-a2-starter/
├── README.md
├── requirements.txt
├── .env.example
├── .gitignore
├── app/
│   ├── app.py                       # Flask entry point
│   ├── config.py                    # đọc cấu hình từ .env
│   ├── db.py                        # kết nối, call_proc, call_function, query_all
│   ├── routes/
│   │   ├── shippers.py              # route màn hình quản lý Shipper
│   │   └── reports.py               # route màn hình procedure/function demo
│   ├── services/
│   │   ├── shipper_service.py       # TODO: CRUD + gọi sp_ListShippers
│   │   └── report_service.py        # TODO: gọi query procedure/function
│   ├── templates/
│   │   ├── base.html
│   │   ├── shippers/list.html
│   │   └── reports/index.html
│   └── static/style.css
└── database/
    ├── 01_create_tables.sql         # TODO: tạo đủ 16 bảng
    ├── 02_sample_data.sql           # TODO: >= 5 dòng / bảng
    ├── 03_triggers.sql              # TODO: 2.2.1 + 2.2.2
    ├── 04_procedures.sql            # TODO: 2.1 + 2.3
    ├── 05_functions.sql             # TODO: 2.4
    ├── run_all.sql
    └── tests/
        ├── test_trigger_business_constraint.sql
        ├── test_trigger_derived_attribute.sql
        └── test_procedures_functions.sql
```

## 3. Phạm vi A2 đã được bố trí trong starter

### 3.1 Database — 7 điểm

| Mục | File | Những việc cần tự hoàn thiện |
|---|---|---|
| 1.1 | `database/01_create_tables.sql` | Tạo đủ 16 bảng từ schema A1; PK, FK, UNIQUE, NOT NULL, DEFAULT, CHECK và các ràng buộc ngữ nghĩa. Từng bảng đã có comment liệt kê thuộc tính cần có. |
| 1.2 | `database/02_sample_data.sql` | Tạo ít nhất 5 dòng dữ liệu có ý nghĩa cho mỗi bảng. File có sẵn thứ tự phụ thuộc FK và checklist 16 bảng. |
| 2.1 | `database/04_procedures.sql` | Viết `sp_InsertShipper`, `sp_UpdateShipper`, `sp_DeleteShipper`; xác thực đầu vào và trả thông báo lỗi cụ thể. Chọn và giải thích chính sách xóa. |
| 2.2.1 | `database/03_triggers.sql` | Trigger kiểm tra ràng buộc A1 #4: một order không có nhiều hơn một assignment đang active. Xử lý INSERT và UPDATE; giải thích vì sao DELETE không gây vi phạm. |
| 2.2.2 | `database/03_triggers.sql` | Trigger tính `SHIPPER.AverageRating` từ feedback do Customer gửi. Xem xét INSERT, UPDATE và DELETE trên FEEDBACK. |
| 2.3 — query 1 | `database/04_procedures.sql` | `sp_ListShippers`: JOIN ít nhất 2 bảng, WHERE, ORDER BY; dùng các tham số lọc. |
| 2.3 — query 2 | `database/04_procedures.sql` | `sp_RevenueByShipper`: JOIN, WHERE, aggregate functions, GROUP BY, HAVING, ORDER BY. |
| 2.4 — function 1 | `database/05_functions.sql` | `fn_ShipperReputation`: input validation, query, cursor, LOOP/IF và kết quả điểm trung bình. |
| 2.4 — function 2 | `database/05_functions.sql` | `fn_ShipperBonus`: input validation, query, cursor, LOOP/IF và công thức thưởng do nhóm thống nhất. |

### 3.2 Chọn ràng buộc cho trigger

Starter chọn sẵn hai mục từ semantic constraints của A1 để nhóm không phải bắt đầu từ trang trắng:

**Trigger business constraint — A1 #4:** một DELIVERY_ORDER không được có hơn một DELIVERY_ASSIGNMENT đang active. Trong starter, trạng thái `accepted` được xem là active. Trigger cần kiểm tra trước INSERT và trước UPDATE khi một assignment trở thành accepted hoặc chuyển sang order khác. DELETE không thể tạo ra tình trạng có hai active assignments, nên không cần trigger DELETE cho ràng buộc này.

**Trigger derived attribute — A1 #14:** `SHIPPER.AverageRating` bằng trung bình rating từ các feedback có `FeedbackType='customer'`. Trigger cần cập nhật giá trị khi FEEDBACK được INSERT, UPDATE hoặc DELETE. Feedback do Shipper gửi không được tính. Nếu chưa có customer feedback, quy ước kết quả là `0.00`.

### 3.3 Application — 3 điểm

- **3.1:** phần đầu trang `/shippers` có form thêm Shipper; mỗi dòng có form sửa ngay và nút xóa.
- **3.2:** cùng trang `/shippers` hiển thị danh sách dự kiến lấy từ `sp_ListShippers`, có ô tìm kiếm, bộ lọc, sắp xếp, form sửa/xóa tại dòng.
- **3.3:** `/reports` chứa form minh họa `sp_RevenueByShipper`, `fn_ShipperReputation` và `fn_ShipperBonus`. Khi làm bài, tối thiểu một trong các procedure/function cần được nối thực tế với giao diện.

## 4. Quy ước về tầng code

- `routes/`: nhận HTTP request, kiểm tra thao tác cơ bản, gọi service và hiển thị thông báo. **Không viết SQL ở route.**
- `services/`: chuẩn hóa/kiểm tra dữ liệu đầu vào ở mức ứng dụng và gọi procedure/function qua `db.py`. Đây là nơi bạn cần hoàn thiện các hàm Python có TODO.
- `db.py`: đã có phần hạ tầng kết nối MySQL và helper `call_proc()`, `call_function()`, `query_all()`. Dùng `call_proc()` cho INSERT/UPDATE/DELETE. Chỉ dùng `query_all()` cho SELECT tra cứu, ví dụ danh sách Admin.
- `database/`: nơi viết DDL, INSERT dữ liệu mẫu, trigger, stored procedure, function và test SQL.

Tất cả hàm Python cần nhóm hoàn thiện đều có docstring/TODO nêu các bước, tham số, kiểm tra dữ liệu, đối tượng SQL cần gọi và kết quả mong đợi.

## 5. Quyết định thiết kế starter cần nhóm xác nhận

1. **Bảng CRUD được chọn:** SHIPPER. `sp_ListShippers` có thể JOIN USER và VEHICLE để hiển thị tên, thông tin liên hệ và xe; nhưng ba thao tác CRUD phải tập trung vào hồ sơ SHIPPER đã chọn. UserID được nhập/chọn từ USER có sẵn.
2. **Chính sách DELETE:** starter gợi ý chỉ xóa vật lý hồ sơ chưa có dữ liệu lịch sử/phụ thuộc. Nếu đã có assignment, earning hoặc feedback, không xóa lịch sử; nhóm có thể từ chối xóa bằng lỗi cụ thể hoặc chuyển tài khoản sang closed/offline. Chọn một phương án nhất quán và giải thích mục đích trong báo cáo.
3. **AverageRating:** nếu dùng trigger để cập nhật thuộc tính này, thêm cột lưu vào SHIPPER trong DDL. Công thức chỉ tính feedback do Customer gửi.
4. **Định nghĩa active assignment:** starter dùng `AssignmentStatus='accepted'`. Nếu nhóm định nghĩa khác, sửa đồng nhất trong trigger, procedure và báo cáo.
5. **Bonus policy:** A1 không quy định ngưỡng/tỷ lệ thưởng. Nhóm phải thống nhất các mức, giải thích đây là giả định thiết kế và sử dụng nhất quán trong function, sample data, test.
6. **Các giá trị ENUM:** đối chiếu với A1 và thống nhất danh sách giá trị giữa DDL, dữ liệu mẫu, procedures và giao diện.

## 6. Lưu ý trước khi chạy SQL

Các file SQL trong thư mục `database/` hiện là **starter templates**, không phải bộ script database hoàn chỉnh. Chúng chứa TODO và ví dụ khung ở dạng comment để bạn tự viết, không tạo ra đủ bảng/procedure/function.

Vì vậy:

1. Chưa cần chạy SQL để mở giao diện Flask.
2. Hoàn thiện `01_create_tables.sql` trước, sau đó `02_sample_data.sql`.
3. Tiếp tục `03_triggers.sql`, `04_procedures.sql`, `05_functions.sql`.
4. Chạy các file test trong `database/tests/` sau khi đối tượng tương ứng đã được tạo.
5. Chỉ khi hoàn tất schema và routines mới cấu hình kết nối thật cho ứng dụng.

**Cảnh báo:** trước khi chạy bất kỳ DDL nào trên database đang có dữ liệu, hãy sao lưu. Starter không tự động DROP database.

## 7. Cấu hình kết nối MySQL khi bắt đầu tích hợp

Sau khi đã có schema:

1. Copy `.env.example` thành `.env` tại thư mục gốc project.
2. Điền tài khoản MySQL của bạn vào `DB_USER` và `DB_PASSWORD`.
3. `DB_NAME` phải trùng tên database trong MySQL, mặc định là `parcel_delivery`.
4. Giữ `.env` ở local; không commit hoặc gửi file này lên Git.

Ví dụ:

```dotenv
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=parcel_delivery
FLASK_SECRET_KEY=replace_with_a_long_random_secret
FLASK_DEBUG=true
PORT=5000
```

## 8. Thứ tự hoàn thiện khuyến nghị

1. Hoàn tất 16 bảng và chạy kiểm tra PK/FK/CHECK.
2. Tạo ít nhất 5 dòng cho từng bảng; xác minh bằng `SELECT COUNT(*)`.
3. Làm 3 procedure CRUD cho SHIPPER và kiểm tra cả trường hợp hợp lệ lẫn lỗi.
4. Làm hai trigger và viết test chứng minh trigger chạy đúng.
5. Làm hai query procedures, sau đó nối `sp_ListShippers` vào trang `/shippers`.
6. Làm hai functions có cursor, sau đó nối ít nhất một function hoặc procedure bổ sung vào `/reports`.
7. Bổ sung xử lý lỗi, kiểm thử tìm kiếm/lọc/sắp xếp và thao tác trực tiếp trên danh sách.

---

**Mục tiêu của starter:** cho phép nhóm chạy được khung giao diện từ đầu, đồng thời để lại điểm bắt đầu rõ ràng cho từng yêu cầu A2 mà không đưa sẵn lời giải nghiệp vụ hoàn chỉnh.
