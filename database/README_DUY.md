# Phần Duy

Đã điền hai bảng DELIVERY_ORDER và ORDER_STATUS_LOG, dữ liệu 5 đơn / 12 dòng lịch sử, trigger trg_order_preserve_completed và kiểm thử trong các file chung. Không tạo bảng DiaDiem.

## Tích hợp

- USER(UserID) và CUSTOMER(UserID) chưa được hiện thực trong starter. Hoàn thiện chúng trước khi chạy DDL của Duy; khóa tham chiếu hiện là INT có dấu.
- Dữ liệu cần USER và CUSTOMER ID 91001..91005. Dành OrderID 92001..92005 và StatusLogID 93001..93012 cho bộ này, hoặc đổi đồng bộ dữ liệu và test.
- Giữ các trạng thái placed, accepted, delivering, completed, cancelled. ServiceType mẫu là Standard. Quy tắc Distance >= 0 được giữ từ phần đã làm; starter gợi ý > 0, cần nhóm thống nhất trước khi đổi.
- Hoàn thiện các bảng còn lại trước khi chạy run_all.sql. Bản đóng góp này không làm toàn bộ starter trở thành database hoàn chỉnh.
- Chạy database/tests/test_trigger_business_constraint.sql trong kết nối riêng không có giao dịch đang làm dở. Kỳ vọng Result 1..5 PASS, Result 6 FailedTests=0 và ALL PASS. Mỗi test rollback dữ liệu và helper được xóa cuối script.

## Lựa chọn trigger

README gốc của starter đề xuất A1 #4 (tối đa một assignment accepted), nhưng phần Duy đã triển khai và kiểm thử là phần A1 #6: đơn completed không đổi sang trạng thái khác. Mục 2.2.1 và test tương ứng sử dụng lựa chọn này. UPDATE có thể vi phạm; INSERT không có OLD status; DELETE nằm ngoài quy tắc. CHECK không thể so sánh trạng thái cũ và mới.

Trigger chưa kiểm tra assignment hoàn tất, chưa tự ghi lịch sử, chưa thực thi A1 #4. Nhóm vẫn cần phân công các ràng buộc đó và dữ liệu PACKAGE/DELIVERY_ASSIGNMENT liên quan. Không thêm bảng USER/CUSTOMER giả của demo vào repo chung.

## Kiểm chứng

Bộ test gốc đã được người dùng chạy trong Workbench với ảnh FailedTests=0, ALL PASS. Các script tích hợp vẫn phụ thuộc phần nhóm A; không coi ảnh demo đó là bằng chứng toàn bộ repo đã chạy thành công.
