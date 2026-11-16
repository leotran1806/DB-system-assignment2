# Báo Cáo Công Việc Của Lê Tuấn (Nhóm C & Mục 2.2.2)

## 1. Tổng quan phân công
- **Thành viên phụ trách:** Lê Tuấn
- **Phần việc 1 (Mục 1.1 & 1.2):** Thiết kế bảng DDL và nhập dữ liệu mẫu cho **Nhóm C** (Thanh toán, Khuyến mãi, Đánh giá):
  1. `PAYMENT` (Thanh toán đơn hàng)
  2. `PROMOTION` (Voucher/mã khuyến mãi)
  3. `APPLIED_TO` (Bảng liên kết đơn hàng - khuyến mãi)
  4. `POINT_TRANSACTION` (Giao dịch tích/đổi điểm thưởng khách hàng)
  5. `FEEDBACK` (Đánh giá sau khi giao hàng)
  6. `SHIPPER_EARNING` (Thu nhập và đối soát hoa hồng tài xế)
- **Phần việc 2 (Mục 2.2.2):** Thiết kế và hiện thực bộ trigger tính toán thuộc tính dẫn xuất:
  - Thuộc tính dẫn xuất được chọn: `SHIPPER.AverageRating`
  - Bảng tác động: `FEEDBACK`
  - Các thao tác DML làm thay đổi giá trị: `INSERT`, `UPDATE`, `DELETE`
  - Viết script kiểm thử: `database/tests/test_trigger2.sql` (và `database/tests/test_trigger_derived_attribute.sql`)

---

## 2. Chi tiết cài đặt bảng nhóm C (`01_create_tables.sql`)

Tất cả bảng đều dùng chuẩn `InnoDB`, bảng mã `utf8mb4` và tích hợp đầy đủ các ràng buộc theo Báo cáo Assignment 1:

1. **`PAYMENT`**:
   - `PaymentID` (INT AUTO_INCREMENT, PK)
   - `OrderID` (INT NOT NULL, UNIQUE, FK -> `DELIVERY_ORDER(OrderID)`): Mỗi đơn hàng có tối đa 1 thanh toán thành công (quan hệ 1-1).
   - `PaymentMethod`: CHECK (`'cash'`, `'card'`, `'e_wallet'`, `'bank_transfer'`)
   - `PaidBy`: CHECK (`'sender'`, `'recipient'`)
   - `Amount`: CHECK (`Amount > 0`)
   - `PaymentStatus`: CHECK (`'completed'`, `'pending'`, `'refunded'`)
   - `TransactionCode`: UNIQUE (mã giao dịch đối soát ngân hàng/ví điện tử)
   - `PaymentDate`: DATETIME DEFAULT CURRENT_TIMESTAMP

2. **`PROMOTION`**:
   - `PromotionID` (INT AUTO_INCREMENT, PK)
   - `PromotionCode` (VARCHAR(50) UNIQUE)
   - `DiscountType`: CHECK (`'percentage'`, `'fixed'`)
   - `DiscountValue`: CHECK (`DiscountValue > 0`), nếu là percentage thì CHECK (`DiscountValue <= 100`)
   - `MaximumDiscount`: CHECK (`MaximumDiscount IS NULL OR MaximumDiscount >= 0`)
   - `MinimumOrderValue`: CHECK (`MinimumOrderValue >= 0`)
   - `StartDate`, `EndDate`: CHECK (`EndDate >= StartDate`)
   - `UsageLimit`: CHECK (`UsageLimit > 0`)
   - `PromotionStatus`: CHECK (`'active'`, `'inactive'`, `'expired'`)

3. **`APPLIED_TO`**:
   - Composite PK: `(OrderID, PromotionID)`
   - FK `OrderID` -> `DELIVERY_ORDER(OrderID)` (ON DELETE CASCADE)
   - FK `PromotionID` -> `PROMOTION(PromotionID)`
   - `DiscountAmount`: CHECK (`DiscountAmount >= 0`)
   - `AppliedDate`: DATETIME

4. **`POINT_TRANSACTION`**:
   - `PointTransactionID` (INT AUTO_INCREMENT, PK)
   - `CustomerID` (FK -> `CUSTOMER(UserID)`)
   - `OrderID` (FK -> `DELIVERY_ORDER(OrderID)`, UNIQUE khi có liên kết đơn hàng)
   - `PointAmount` (INT, có thể âm hoặc dương)
   - `TransactionType`: CHECK (`'earn'`, `'redeem'`, `'adjustment'`)
   - Ràng buộc: `earn` yêu cầu `PointAmount > 0`; `redeem` yêu cầu `PointAmount < 0`

5. **`FEEDBACK`**:
   - `FeedbackID` (INT AUTO_INCREMENT, PK)
   - `OrderID` (FK -> `DELIVERY_ORDER(OrderID)`)
   - `CustomerID` (FK -> `CUSTOMER(UserID)`)
   - `ShipperID` (FK -> `SHIPPER(UserID)`)
   - `Rating`: CHECK (`Rating BETWEEN 1 AND 5`)
   - `FeedbackType`: CHECK (`'customer'`, `'shipper'`)
   - Ràng buộc ngữ nghĩa A1 #13: mỗi bên chỉ được đánh giá tối đa 1 lần cho mỗi đơn hàng -> `UNIQUE (OrderID, FeedbackType)`

6. **`SHIPPER_EARNING`**:
   - `EarningID` (INT AUTO_INCREMENT, PK)
   - `OrderID` (INT UNIQUE, FK -> `DELIVERY_ORDER(OrderID)`): Mỗi đơn hoàn tất có duy nhất 1 bản ghi thu nhập.
   - `ShipperID` (FK -> `SHIPPER(UserID)`)
   - `DeliveryFee`: CHECK (`DeliveryFee >= 0`)
   - `PlatformCommission`: CHECK (`PlatformCommission >= 0 AND PlatformCommission <= DeliveryFee`)
   - `NetEarning`: Cột sinh tự động `GENERATED ALWAYS AS (DeliveryFee - PlatformCommission) STORED` đảm bảo luôn chính xác.
   - `PayoutStatus`: CHECK (`'pending'`, `'processing'`, `'paid'`, `'cancelled'`)
   - `PayoutDate`: Khi `'paid'` thì bắt buộc `PayoutDate >= EarningDate`, ngược lại `PayoutDate IS NULL`.

---

## 3. Dữ liệu mẫu nhóm C (`02_sample_data.sql`)

Đã nạp đầy đủ $\ge 5$ dòng dữ liệu có nghĩa cho mỗi bảng:
- **`PROMOTION`**: 6 khuyến mãi đa dạng (giảm %, giảm cố định, đang hoạt động, hết hạn, tạm ngưng).
- **`DELIVERY_ORDER`**: Bổ sung các đơn đã hoàn thành (`92006..92010`) kèm log trạng thái và tài khoản phụ thuộc để hỗ trợ hoàn chỉnh dữ liệu cho `FEEDBACK`, `PAYMENT`, `APPLIED_TO`, `SHIPPER_EARNING`.
- **`PAYMENT`**: 6 bản ghi thanh toán với các phương thức tiền mặt, thẻ, ví điện tử.
- **`APPLIED_TO`**: 6 bản ghi áp dụng voucher hợp lệ.
- **`POINT_TRANSACTION`**: 7 bản ghi tích điểm từ đơn hàng và đổi điểm thưởng.
- **`FEEDBACK`**: 6 bản ghi đánh giá gồm cả khách hàng đánh giá tài xế và tài xế đánh giá khách hàng.
- **`SHIPPER_EARNING`**: 6 bản ghi thu nhập cho các tài xế hoàn thành đơn hàng, tương thích với thủ tục doanh thu `sp_RevenueByShipper` và hàm tính thưởng `fn_ShipperBonus`.

---

## 4. Trigger thuộc tính dẫn xuất 2.2.2 (`03_triggers.sql`)

### 4.1. Quy tắc nghiệp vụ và công thức tính
- **Thuộc tính dẫn xuất:** `SHIPPER.AverageRating` (DECIMAL(3,2))
- **Đặc tả A1 #14:** Điểm đánh giá trung bình của tài xế bằng trung bình cộng `Rating` từ các đánh giá do **Khách hàng** gửi (`FeedbackType = 'customer'`). Đánh giá do tài xế gửi về khách hàng (`FeedbackType = 'shipper'`) tuyệt đối không được tính vào điểm này.
- **Quy ước rỗng:** Nếu tài xế chưa có đánh giá nào từ khách hàng (hoặc bị xóa hết), điểm số được quy ước là `0.00`.
- **Công thức:**
  ```sql
  UPDATE SHIPPER
  SET AverageRating = COALESCE((
      SELECT ROUND(AVG(Rating), 2)
      FROM FEEDBACK
      WHERE ShipperID = <AffectedShipperID>
        AND FeedbackType = 'customer'
  ), 0.00)
  WHERE UserID = <AffectedShipperID>;
  ```

### 4.2. Các thao tác DML ảnh hưởng
1. **`AFTER INSERT ON FEEDBACK` (`trg_feedback_after_insert`):**
   - Khi thêm mới feedback, nếu `NEW.FeedbackType = 'customer'`, tự động cập nhật `AverageRating` cho tài xế `NEW.ShipperID`.
2. **`AFTER UPDATE ON FEEDBACK` (`trg_feedback_after_update`):**
   - Nếu đổi `ShipperID` (chuyển đánh giá sang tài xế khác): tính lại cho cả `OLD.ShipperID` và `NEW.ShipperID`.
   - Nếu đổi `Rating` hoặc đổi `FeedbackType`: tính lại cho tài xế bị ảnh hưởng.
3. **`AFTER DELETE ON FEEDBACK` (`trg_feedback_after_delete`):**
   - Khi xóa một đánh giá khách hàng, tự động tính lại cho `OLD.ShipperID`. Nếu không còn đánh giá nào, trả về `0.00`.

---

## 5. Kịch bản kiểm thử (`database/tests/test_trigger2.sql`)

Thực hiện kiểm thử tự động thông qua procedure `tuan_test_trigger2()` với 7 test case:

| Test | Thao tác thực hiện | Kỳ vọng |
|---|---|---|
| **T1** | Kiểm tra tài xế chưa có đánh giá khách hàng (Shipper 23) | `AverageRating = 0.00` |
| **T2** | `INSERT` 1 đánh giá khách hàng (Rating = 4) | `AverageRating = 4.00` |
| **T3** | `INSERT` thêm đánh giá khách hàng thứ 2 (Rating = 5) | `AverageRating = (4+5)/2 = 4.50` |
| **T4** | `INSERT` đánh giá từ tài xế (`FeedbackType='shipper'`, Rating = 1) | `AverageRating` không đổi, vẫn giữ nguyên `4.50` |
| **T5** | `UPDATE` sửa rating của đánh giá thứ nhất từ 4 thành 2 | `AverageRating = (2+5)/2 = 3.50` |
| **T6** | `UPDATE` chuyển ShipperID của đánh giá từ tài xế 23 sang tài xế 22 | Tài xế cũ 23 còn lại 5.00; Tài xế mới 22 nhận 2.00 (cả 2 đều cập nhật đúng) |
| **T7** | `DELETE` đánh giá khách hàng của tài xế | Tài xế về 0 đánh giá -> `AverageRating = 0.00` |

- **An toàn dữ liệu:** Toàn bộ test case chạy trong `START TRANSACTION` và gọi `ROLLBACK` ngay sau khi đối soát, giúp dữ liệu mẫu ban đầu được bảo toàn nguyên vẹn.
- **Kết quả:** `FailedTests = 0`, `ALL PASS`.
