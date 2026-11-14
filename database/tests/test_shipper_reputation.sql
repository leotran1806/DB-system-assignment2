-- =====================================================================
-- TEST fn_ShipperReputation  
-- Chạy SAU khi bảng FEEDBACK và dữ liệu mẫu FEEDBACK đã được nạp,
-- và sau khi chạy 05_functions.sql.
-- =====================================================================
USE parcel_delivery;

-- T1. Gọi hàm cho mọi shipper. Shipper chưa có đánh giá khách hàng -> 0.00
SELECT s.UserID, fn_ShipperReputation(s.UserID) AS Reputation, s.AverageRating
  FROM SHIPPER s
 ORDER BY s.UserID;

-- T2. Đối chiếu bằng SQL thuần: FnValue phải bằng ExpectedValue ở mọi dòng.
--     Công thức: trung bình có trọng số; đánh giá trong 30 ngày tính từ đánh giá
--     mới nhất của shipper có trọng số 2, còn lại trọng số 1; không có đánh giá -> 0.00
SELECT x.UserID,
       x.FnValue,
       x.ExpectedValue,
       IF(x.FnValue = x.ExpectedValue, 'OK', 'MISMATCH') AS Result
  FROM (
        SELECT s.UserID,
               fn_ShipperReputation(s.UserID) AS FnValue,
               COALESCE(ROUND(
                   SUM(f.Rating * IF(DATEDIFF(m.LatestDate, DATE(f.CreatedDate)) <= 30, 2, 1))
                 / SUM(IF(DATEDIFF(m.LatestDate, DATE(f.CreatedDate)) <= 30, 2, 1)), 2), 0.00)
                   AS ExpectedValue
          FROM SHIPPER s
          LEFT JOIN FEEDBACK f
                 ON f.ShipperID = s.UserID AND f.FeedbackType = 'customer'
          LEFT JOIN (SELECT ShipperID, MAX(DATE(CreatedDate)) AS LatestDate
                       FROM FEEDBACK
                      WHERE FeedbackType = 'customer'
                      GROUP BY ShipperID) m
                 ON m.ShipperID = s.UserID
         GROUP BY s.UserID, m.LatestDate
       ) x
 ORDER BY x.UserID;

-- T3. Kiểm tra giá trị nằm trong [0, 5] -> kết quả phải là 0 dòng
SELECT s.UserID, fn_ShipperReputation(s.UserID) AS Reputation
  FROM SHIPPER s
 WHERE fn_ShipperReputation(s.UserID) < 0 OR fn_ShipperReputation(s.UserID) > 5;

-- T4. Shipper 25 không có xe và (thường) chưa có đánh giá -> 0.00 (nhánh "không có dữ liệu")
SELECT fn_ShipperReputation(25) AS Reputation_Shipper25;

-- =====================================================================
-- Trường hợp LỖI (mỗi lệnh phải báo lỗi 1644 / SQLSTATE 45000). Chạy từng dòng.
-- =====================================================================
-- SELECT fn_ShipperReputation(NULL);  -- ShipperID must be a positive integer.
-- SELECT fn_ShipperReputation(0);     -- ShipperID must be a positive integer.
-- SELECT fn_ShipperReputation(9999);  -- Shipper does not exist.
-- SELECT fn_ShipperReputation(1);     -- UserID 1 là ADMIN, không phải SHIPPER -> Shipper does not exist.
