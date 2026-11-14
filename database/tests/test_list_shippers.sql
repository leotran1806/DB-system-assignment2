-- =====================================================================
-- TEST sp_ListShippers 
-- Chạy SAU 01_create_tables.sql, 02_sample_data.sql, 04_procedures.sql.
-- Tham số: (search, availability, account_status, vehicle_type, sort_by, user_id)
-- Kết quả mong đợi dựa trên sample data hiện tại (shipper 16..25).
-- =====================================================================
USE parcel_delivery;

-- T1. Không lọc -> 10 dòng; shipper 25 có VehicleType = NULL (LEFT JOIN)
CALL sp_ListShippers(NULL, NULL, NULL, NULL, 'name', NULL);

-- T2. availability = available -> 4 dòng (16, 17, 19, 22)
CALL sp_ListShippers(NULL, 'available', NULL, NULL, 'name', NULL);

-- T3. availability = busy -> 2 dòng (18, 21)
CALL sp_ListShippers(NULL, 'busy', NULL, NULL, 'name', NULL);

-- T4. account_status = suspended -> 1 dòng (24);  closed -> 1 dòng (25)
CALL sp_ListShippers(NULL, NULL, 'suspended', NULL, 'name', NULL);
CALL sp_ListShippers(NULL, NULL, 'closed', NULL, 'name', NULL);

-- T5. vehicle_type: motorbike -> 5 (16..20); car -> 2 (21, 22); van -> 1 (23); truck -> 1 (24)
--     (shipper 25 không có xe nên không xuất hiện khi lọc theo loại xe)
CALL sp_ListShippers(NULL, NULL, NULL, 'motorbike', 'name', NULL);
CALL sp_ListShippers(NULL, NULL, NULL, 'car', 'name', NULL);

-- T6. Lọc kết hợp: available + car -> 1 dòng (22);  available + motorbike -> 3 dòng (16, 17, 19)
CALL sp_ListShippers(NULL, 'available', NULL, 'car', 'name', NULL);
CALL sp_ListShippers(NULL, 'available', NULL, 'motorbike', 'name', NULL);

-- T7. Tìm kiếm: theo email, SĐT, mã định danh, tên (không phân biệt hoa/thường, dấu)
CALL sp_ListShippers('phuc.nguyen', NULL, NULL, NULL, 'name', NULL);   -- 1 dòng (16)
CALL sp_ListShippers('0971000016', NULL, NULL, NULL, 'name', NULL);    -- 1 dòng (16)
CALL sp_ListShippers('079095123401', NULL, NULL, NULL, 'name', NULL);  -- 1 dòng (16)
CALL sp_ListShippers('Nguyễn Hoàng', NULL, NULL, NULL, 'name', NULL);  -- 1 dòng (16)
CALL sp_ListShippers('  phuc  ', NULL, NULL, NULL, 'name', NULL);      -- TRIM -> 1 dòng (16)

-- T8. Ký tự wildcard được escape: '%' và '_' tìm đúng ký tự -> 0 dòng
CALL sp_ListShippers('%', NULL, NULL, NULL, 'name', NULL);
CALL sp_ListShippers('_', NULL, NULL, NULL, 'name', NULL);

-- T9. Sắp xếp
--   join_date  : JoinDate mới nhất trước -> 25, 24, 23, 22, 21, 20, 19, 18, 17, 16
CALL sp_ListShippers(NULL, NULL, NULL, NULL, 'join_date', NULL);
--   availability: available (16,17,19,22) -> busy (18,21) -> offline (20,23,24,25)
CALL sp_ListShippers(NULL, NULL, NULL, NULL, 'availability', NULL);
--   rating: AverageRating giảm dần; khi trigger 2.2.2 chưa chạy, tất cả = 0.00 -> xếp theo tên
CALL sp_ListShippers(NULL, NULL, NULL, NULL, 'rating', NULL);
--   sort rỗng/NULL -> mặc định 'name'
CALL sp_ListShippers(NULL, NULL, NULL, NULL, NULL, NULL);
CALL sp_ListShippers(NULL, NULL, NULL, NULL, '', NULL);

-- T10. Lấy 1 shipper theo UserID (dùng cho get_shipper)
CALL sp_ListShippers(NULL, NULL, NULL, NULL, 'name', 16);    -- 1 dòng
CALL sp_ListShippers(NULL, NULL, NULL, NULL, 'name', 9999);  -- 0 dòng

-- T11. Chuỗi rỗng được coi là "không lọc" -> 10 dòng
CALL sp_ListShippers('', '', '', '', 'name', NULL);

-- =====================================================================
-- Trường hợp LỖI: mỗi lệnh dưới đây phải báo lỗi 1644 (SQLSTATE 45000).
-- Bỏ comment và chạy TỪNG DÒNG (một lỗi sẽ dừng cả script nếu chạy cùng nhau).
-- =====================================================================
-- CALL sp_ListShippers(NULL, 'sleeping', NULL, NULL, 'name', NULL);  -- AvailabilityStatus must be ...
-- CALL sp_ListShippers(NULL, NULL, 'banned', NULL, 'name', NULL);    -- AccountStatus must be ...
-- CALL sp_ListShippers(NULL, NULL, NULL, 'bicycle', 'name', NULL);   -- VehicleType must be ...
-- CALL sp_ListShippers(NULL, NULL, NULL, NULL, 'name; DROP TABLE SHIPPER', NULL); -- SortBy must be ...
-- CALL sp_ListShippers(NULL, NULL, NULL, NULL, 'name', 0);           -- UserID must be a positive integer.
-- CALL sp_ListShippers(NULL, NULL, NULL, NULL, 'name', -5);          -- UserID must be a positive integer.

-- Lưu ý: thứ tự các tên bắt đầu bằng 'Đ' (Đạt) phụ thuộc collation utf8mb4_unicode_ci;
-- khi kiểm tra sort theo tên, chỉ cần xác nhận kết quả được sắp tăng dần theo FirstName.
