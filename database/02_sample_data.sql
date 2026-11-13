-- ============================================================================
-- 02_sample_data.sql | A2 - Section 1.2 (1 point)
-- STARTER FILE: add meaningful INSERT statements. Do not leave this file empty.
-- Requirement: at least 5 rows in EACH of the 16 tables.
-- ============================================================================
USE parcel_delivery;

-- IMPORTANT: respect foreign-key dependency order. A recommended order is:
-- 1 USER (insert enough distinct accounts for Customer, Shipper and Admin roles)
-- 2 ADMIN, CUSTOMER, SHIPPER
-- 3 SHIPPER_LICENSE, VEHICLE, PROMOTION
-- 4 DELIVERY_ORDER
-- 5 PACKAGE, DELIVERY_ASSIGNMENT, ORDER_STATUS_LOG, PAYMENT, APPLIED_TO
-- 6 POINT_TRANSACTION, FEEDBACK, SHIPPER_EARNING
--
-- For EVERY table below, prepare at least FIVE meaningful rows, not five copies
-- of the same values. Include different statuses and boundary cases so the
-- CHECK constraints, triggers, procedures and functions can be demonstrated.

-- ============================================================================
-- TODO 1: USER (28 rows). Roles are disjoint: each UserID 1-25 belongs to exactly one subclass.
--         26-28 have no role yet; they are the candidates used to demonstrate sp_InsertShipper.
INSERT INTO `USER` (UserID, Email, PhoneNumber, PasswordHash, AccountStatus, CreatedDate, DateOfBirth, Gender, FirstName, LastName) VALUES
(1, 'an.nguyen@parceldelivery.vn', '0901000001', SHA2('Password@123', 256), 'active', '2024-01-10', '1980-05-12', 'male', 'An', 'Nguyễn Văn'),
(2, 'binh.tran@parceldelivery.vn', '0901000002', SHA2('Password@123', 256), 'active', '2024-02-15', '1985-09-03', 'female', 'Bình', 'Trần Thị'),
(3, 'cuong.le@parceldelivery.vn', '0901000003', SHA2('Password@123', 256), 'active', '2024-03-01', '1983-11-21', 'male', 'Cường', 'Lê Quốc'),
(4, 'dung.pham@parceldelivery.vn', '0901000004', SHA2('Password@123', 256), 'active', '2024-06-20', '1990-02-14', 'female', 'Dung', 'Phạm Thùy'),
(5, 'khang.hoang@parceldelivery.vn', '0901000005', SHA2('Password@123', 256), 'suspended', '2024-08-05', '1992-07-30', 'male', 'Khang', 'Hoàng Gia'),
(6, 'lan.nguyen@mail.com', '0912000006', SHA2('Password@123', 256), 'active', '2025-01-05', '1995-03-18', 'female', 'Lan', 'Nguyễn Thị'),
(7, 'hung.vo@mail.com', '0912000007', SHA2('Password@123', 256), 'active', '2025-01-12', '1990-08-25', 'male', 'Hùng', 'Võ Mạnh'),
(8, 'mai.dang@mail.com', '0912000008', SHA2('Password@123', 256), 'active', '2025-02-03', '1998-12-02', 'female', 'Mai', 'Đặng Thị'),
(9, 'tuan.bui@mail.com', '0912000009', SHA2('Password@123', 256), 'active', '2025-02-20', '1988-06-09', 'male', 'Tuấn', 'Bùi Anh'),
(10, 'hoa.ngo@mail.com', '0912000010', SHA2('Password@123', 256), 'active', '2025-03-14', '2001-01-27', 'female', 'Hoa', 'Ngô Thị'),
(11, 'nam.do@mail.com', '0912000011', SHA2('Password@123', 256), 'active', '2025-04-02', '1993-10-11', 'male', 'Nam', 'Đỗ Hoàng'),
(12, 'thao.vu@mail.com', '0912000012', SHA2('Password@123', 256), 'active', '2025-05-19', '1997-04-30', 'female', 'Thảo', 'Vũ Phương'),
(13, 'long.dinh@mail.com', '0912000013', SHA2('Password@123', 256), 'active', '2025-06-08', '2003-09-15', 'male', 'Long', 'Đinh Thanh'),
(14, 'yen.truong@mail.com', '0912000014', SHA2('Password@123', 256), 'suspended', '2025-07-21', '1994-02-08', 'female', 'Yến', 'Trương Hải'),
(15, 'quang.ly@mail.com', '0912000015', SHA2('Password@123', 256), 'closed', '2025-08-30', '1989-12-19', 'male', 'Quang', 'Lý Minh'),
(16, 'phuc.nguyen@mail.com', '0971000016', SHA2('Password@123', 256), 'active', '2025-01-08', '1995-04-10', 'male', 'Phúc', 'Nguyễn Hoàng'),
(17, 'tai.tran@mail.com', '0971000017', SHA2('Password@123', 256), 'active', '2025-01-20', '1992-09-23', 'male', 'Tài', 'Trần Đức'),
(18, 'ngoc.le@mail.com', '0971000018', SHA2('Password@123', 256), 'active', '2025-02-10', '1997-06-05', 'female', 'Ngọc', 'Lê Bảo'),
(19, 'son.pham@mail.com', '0971000019', SHA2('Password@123', 256), 'active', '2025-03-03', '1994-01-17', 'male', 'Sơn', 'Phạm Trường'),
(20, 'trang.vu@mail.com', '0971000020', SHA2('Password@123', 256), 'active', '2025-03-25', '1999-11-28', 'female', 'Trang', 'Vũ Thu'),
(21, 'khoa.dang@mail.com', '0971000021', SHA2('Password@123', 256), 'active', '2025-04-12', '1991-07-14', 'male', 'Khoa', 'Đặng Anh'),
(22, 'huy.bui@mail.com', '0971000022', SHA2('Password@123', 256), 'active', '2025-05-05', '2000-03-02', 'male', 'Huy', 'Bùi Quang'),
(23, 'linh.ho@mail.com', '0971000023', SHA2('Password@123', 256), 'active', '2025-06-01', '1996-08-19', 'female', 'Linh', 'Hồ Thùy'),
(24, 'dat.truong@mail.com', '0971000024', SHA2('Password@123', 256), 'suspended', '2025-06-18', '1993-05-26', 'male', 'Đạt', 'Trương Tiến'),
(25, 'hieu.ly@mail.com', '0971000025', SHA2('Password@123', 256), 'closed', '2025-07-02', '1990-10-08', 'male', 'Hiếu', 'Lý Trung'),
(26, 'khoa.nguyen@mail.com', '0981000026', SHA2('Password@123', 256), 'active', '2026-10-01', '1998-06-15', 'male', 'Khoa', 'Nguyễn Đăng'),
(27, 'bao.tran@mail.com', '0981000027', SHA2('Password@123', 256), 'active', '2026-10-15', '2010-03-15', 'male', 'Bảo', 'Trần Gia'),
(28, 'vy.le@mail.com', '0981000028', SHA2('Password@123', 256), 'suspended', '2026-09-20', '1996-12-01', 'female', 'Vy', 'Lê Khánh');

-- TODO 2: ADMIN (5 rows). Supervisors are inserted before their subordinates; admin 5 is suspended.
INSERT INTO ADMIN (UserID, EmployeeCode, Department, AccessLevel, HireDate, Supervisor_ID) VALUES
(1, 'AD001', 'Operations', 3, '2024-01-10', NULL),
(2, 'AD002', 'Customer Support', 2, '2024-02-15', 1),
(3, 'AD003', 'Finance', 2, '2024-03-01', 1),
(4, 'AD004', 'Technical', 1, '2024-06-20', 2),
(5, 'AD005', 'Human Resources', 1, '2024-08-05', 3);

-- TODO 3: CUSTOMER (10 rows). Customer 14 is suspended and 15 is closed (they must not create new orders).
-- NOTE: LoyaltyPoint must equal earned minus redeemed points in POINT_TRANSACTION (constraint 15).
INSERT INTO CUSTOMER (UserID, LoyaltyPoint) VALUES
(6, 1200),
(7, 350),
(8, 0),
(9, 2500),
(10, 90),
(11, 640),
(12, 150),
(13, 30),
(14, 500),
(15, 0);

-- TODO 4: SHIPPER (10 rows). AverageRating is left at its default 0.00; the trigger of 2.2.2 computes it from FEEDBACK.
-- Shipper 24 is suspended and 25 is closed, so both are offline. Admin 5 (suspended) manages nobody.
INSERT INTO SHIPPER (UserID, NationalIdentificationNumber, AvailabilityStatus, JoinDate, ManagedByAdminID) VALUES
(16, '079095123401', 'available', '2025-01-15', 1),
(17, '001092234502', 'available', '2025-02-01', 1),
(18, '048197345603', 'busy', '2025-02-20', 2),
(19, '092094456704', 'available', '2025-03-10', 2),
(20, '075199567805', 'offline', '2025-04-01', 3),
(21, '074091678906', 'busy', '2025-04-20', 3),
(22, '031200789007', 'available', '2025-05-12', 4),
(23, '056196890108', 'offline', '2025-06-10', 4),
(24, '087093901209', 'offline', '2025-06-25', 2),
(25, '038090012310', 'offline', '2025-07-09', 3);

-- TODO 6: VEHICLE (9 rows). One vehicle per shipper; shipper 25 has no vehicle.
INSERT INTO VEHICLE (VehicleID, ShipperID, Brand, Model, LicensePlate, Color, MaximumLoad, VehicleType) VALUES
(1, 16, 'Honda', 'Wave Alpha', '59X1-234.56', 'Red', 40, 'motorbike'),
(2, 17, 'Yamaha', 'Exciter', '29B1-345.67', 'Black', 50, 'motorbike'),
(3, 18, 'Honda', 'Air Blade', '43E1-456.78', 'White', 45, 'motorbike'),
(4, 19, 'Honda', 'Vision', '65G1-567.89', 'Blue', 40, 'motorbike'),
(5, 20, 'Yamaha', 'Sirius', '60B1-678.90', 'Silver', 40, 'motorbike'),
(6, 21, 'Toyota', 'Vios', '51A-123.45', 'White', 400, 'car'),
(7, 22, 'Kia', 'Morning', '30E-456.78', 'Silver', 350, 'car'),
(8, 23, 'Hyundai', 'Solati', '51C-789.01', 'White', 900, 'van'),
(9, 24, 'Isuzu', 'QKR', '29C-890.12', 'Blue', 1900, 'truck');

-- Row-count check for this group (each must be >= 5):
SELECT 'USER' AS TableName, COUNT(*) AS Total FROM `USER`
UNION ALL SELECT 'ADMIN', COUNT(*) FROM ADMIN
UNION ALL SELECT 'CUSTOMER', COUNT(*) FROM CUSTOMER
UNION ALL SELECT 'SHIPPER', COUNT(*) FROM SHIPPER
UNION ALL SELECT 'VEHICLE', COUNT(*) FROM VEHICLE;

-- ============================================================================
-- GROUP C DATA: PROMOTION — Lê Tuấn (6 rows)
-- ============================================================================
INSERT INTO PROMOTION (PromotionID, PromotionCode, PromotionName, Description, DiscountType, DiscountValue, MaximumDiscount, MinimumOrderValue, StartDate, EndDate, UsageLimit, PromotionStatus) VALUES
(1, 'SUMMER2026', 'Summer Sale 10%', '10% discount for orders above 50k', 'percentage', 10.00, 50000.00, 50000.00, '2026-06-01 00:00:00', '2026-12-31 23:59:59', 1000, 'active'),
(2, 'FREESHIP25', 'Free Shipping 25k', 'Fixed 25k discount on shipping fee', 'fixed', 25000.00, 25000.00, 30000.00, '2026-01-01 00:00:00', '2026-12-31 23:59:59', 500, 'active'),
(3, 'WELCOME50', 'New Customer 50%', '50% off first delivery up to 40k', 'percentage', 50.00, 40000.00, 0.00, '2026-01-01 00:00:00', '2026-12-31 23:59:59', 200, 'active'),
(4, 'BIGSAVER30', 'Big Saver 30k', '30k off for bulky/heavy deliveries', 'fixed', 30000.00, 30000.00, 100000.00, '2026-03-01 00:00:00', '2026-12-31 23:59:59', 300, 'active'),
(5, 'FLASHVIP20', 'VIP Special 20%', 'Exclusive discount for loyal VIP customers', 'percentage', 20.00, 100000.00, 80000.00, '2026-05-01 00:00:00', '2026-11-30 23:59:59', 150, 'inactive'),
(6, 'TET2026', 'Tet Holiday Promo', 'Fixed 20k off during Tet festival', 'fixed', 20000.00, 20000.00, 40000.00, '2026-01-20 00:00:00', '2026-02-10 23:59:59', 500, 'expired');

-- Demo customer accounts 91001..91005 for Duy's demo orders (Group B integration dependency):
INSERT IGNORE INTO `USER` (UserID, Email, PhoneNumber, PasswordHash, AccountStatus, CreatedDate, DateOfBirth, Gender, FirstName, LastName) VALUES
(91001, 'demo1@parceldelivery.vn', '0919000001', SHA2('Password@123', 256), 'active', '2025-01-01', '1990-01-01', 'male', 'Van', 'Nguyen'),
(91002, 'demo2@parceldelivery.vn', '0919000002', SHA2('Password@123', 256), 'active', '2025-01-01', '1991-01-01', 'female', 'Thi', 'Tran'),
(91003, 'demo3@parceldelivery.vn', '0919000003', SHA2('Password@123', 256), 'active', '2025-01-01', '1992-01-01', 'male', 'Van', 'Le'),
(91004, 'demo4@parceldelivery.vn', '0919000004', SHA2('Password@123', 256), 'active', '2025-01-01', '1993-01-01', 'female', 'Thi', 'Pham'),
(91005, 'demo5@parceldelivery.vn', '0919000005', SHA2('Password@123', 256), 'active', '2025-01-01', '1994-01-01', 'male', 'Van', 'Hoang');

INSERT IGNORE INTO CUSTOMER (UserID, LoyaltyPoint) VALUES
(91001, 100), (91002, 200), (91003, 300), (91004, 400), (91005, 500);

-- 8: Duy — requires CUSTOMER IDs 91001..91005 from group A.
INSERT INTO DELIVERY_ORDER (OrderID, CustomerID, PickupAddressDetail, PickupDistrict, PickupProvinceCity, DeliveryAddressDetail, DeliveryDistrict, DeliveryProvinceCity, CreatedDate, ServiceType, PickupContactName, PickupContactPhone, DeliveryContactName, DeliveryContactPhone, Distance, CODAmount, OrderStatus, Note, CompleteDate, CancellationReason) VALUES
(92001,91001,'123 Nguyen Van Cu','District 5','Ho Chi Minh City','268 Ly Thuong Kiet','District 10','Ho Chi Minh City','2026-11-01 08:00:00','Standard','Sender 1','0901234501','Receiver 1','0911234501',5.50,100000,'placed','Demo order 1',NULL,NULL),
(92002,91002,'123 Nguyen Van Cu','District 5','Ho Chi Minh City','268 Ly Thuong Kiet','District 10','Ho Chi Minh City','2026-11-01 08:00:00','Standard','Sender 2','0901234502','Receiver 2','0911234502',5.50,100000,'accepted','Demo order 2',NULL,NULL),
(92003,91003,'123 Nguyen Van Cu','District 5','Ho Chi Minh City','268 Ly Thuong Kiet','District 10','Ho Chi Minh City','2026-11-01 08:00:00','Standard','Sender 3','0901234503','Receiver 3','0911234503',5.50,100000,'delivering','Demo order 3',NULL,NULL),
(92004,91004,'123 Nguyen Van Cu','District 5','Ho Chi Minh City','268 Ly Thuong Kiet','District 10','Ho Chi Minh City','2026-11-01 08:00:00','Standard','Sender 4','0901234504','Receiver 4','0911234504',5.50,100000,'completed','Demo order 4','2026-11-01 11:00:00',NULL),
(92005,91005,'123 Nguyen Van Cu','District 5','Ho Chi Minh City','268 Ly Thuong Kiet','District 10','Ho Chi Minh City','2026-11-01 08:00:00','Standard','Sender 5','0901234505','Receiver 5','0911234505',5.50,100000,'cancelled','Demo order 5',NULL,'Customer requested cancellation'),
-- Additional completed orders to support Group C entities (FEEDBACK, SHIPPER_EARNING):
(92006,6,'45 Le Duan','District 1','Ho Chi Minh City','12 Vo Van Ngan','Thu Duc City','Ho Chi Minh City','2026-11-02 08:30:00','Express','Sender 6','0901234506','Receiver 6','0911234506',12.00,0,'completed','Delivered on time','2026-11-02 11:30:00',NULL),
(92007,7,'78 Tran Hung Dao','District 5','Ho Chi Minh City','99 Cong Hoa','Tan Binh District','Ho Chi Minh City','2026-11-02 09:15:00','Standard','Sender 7','0901234507','Receiver 7','0911234507',8.20,50000,'completed','Delivered safely','2026-11-02 13:45:00',NULL),
(92008,9,'101 Cach Mang Thang 8','District 3','Ho Chi Minh City','55 Nguyen Thi Minh Khai','District 1','Ho Chi Minh City','2026-11-03 14:00:00','Standard','Sender 8','0901234508','Receiver 8','0911234508',4.50,200000,'completed','Fragile item delivered','2026-11-03 16:00:00',NULL),
(92009,11,'202 Hoang Van Thu','Phu Nhuan District','Ho Chi Minh City','15 Ba Huyen Thanh Quan','District 3','Ho Chi Minh City','2026-11-04 08:00:00','Express','Sender 9','0901234509','Receiver 9','0911234509',6.00,0,'completed','Fast delivery completed','2026-11-04 10:00:00',NULL),
(92010,12,'88 Nguyen Trai','District 5','Ho Chi Minh City','33 Dien Bien Phu','Binh Thanh District','Ho Chi Minh City','2026-11-04 13:00:00','Standard','Sender 10','0901234510','Receiver 10','0911234510',7.50,150000,'completed','Delivered to recipient','2026-11-04 15:30:00',NULL);

-- TODO 9: INSERT >= 5 PACKAGE rows.
--        Link to existing orders; use meaningful descriptions/categories and
--        valid positive dimensions/weight. Ensure at least one package per order.

-- TODO 10: INSERT >= 5 DELIVERY_ASSIGNMENT rows.
--         Include offered/rejected/accepted/completed statuses and valid dates.
--         Do not seed two simultaneously active assignments for one order.
--
-- 11: Duy — requires USER IDs 91001..91005 from group A.
INSERT INTO ORDER_STATUS_LOG (StatusLogID,OrderID,ChangedByUserID,Status,ChangedDate,Note) VALUES
(93001,92001,91001,'placed','2026-11-01 08:00:00','Demo status history'),
(93002,92002,91002,'placed','2026-11-01 08:00:00','Demo status history'),
(93003,92002,91002,'accepted','2026-11-01 09:00:00','Demo status history'),
(93004,92003,91003,'placed','2026-11-01 08:00:00','Demo status history'),
(93005,92003,91003,'accepted','2026-11-01 09:00:00','Demo status history'),
(93006,92003,91003,'delivering','2026-11-01 10:00:00','Demo status history'),
(93007,92004,91004,'placed','2026-11-01 08:00:00','Demo status history'),
(93008,92004,91004,'accepted','2026-11-01 09:00:00','Demo status history'),
(93009,92004,91004,'delivering','2026-11-01 10:00:00','Demo status history'),
(93010,92004,91004,'completed','2026-11-01 11:00:00','Demo status history'),
(93011,92005,91005,'placed','2026-11-01 08:00:00','Demo status history'),
(93012,92005,91005,'cancelled','2026-11-01 09:00:00','Demo status history'),
-- Status logs for additional completed orders:
(93013,92006,6,'placed','2026-11-02 08:30:00','Order placed'),
(93014,92006,17,'completed','2026-11-02 11:30:00','Order completed'),
(93015,92007,7,'placed','2026-11-02 09:15:00','Order placed'),
(93016,92007,18,'completed','2026-11-02 13:45:00','Order completed'),
(93017,92008,9,'placed','2026-11-03 14:00:00','Order placed'),
(93018,92008,19,'completed','2026-11-03 16:00:00','Order completed'),
(93019,92009,11,'placed','2026-11-04 08:00:00','Order placed'),
(93020,92009,21,'completed','2026-11-04 10:00:00','Order completed'),
(93021,92010,12,'placed','2026-11-04 13:00:00','Order placed'),
(93022,92010,17,'completed','2026-11-04 15:30:00','Order completed');

-- ============================================================================
-- GROUP C DATA: PAYMENT — Lê Tuấn (6 rows)
-- ============================================================================
INSERT INTO PAYMENT (PaymentID, OrderID, PaymentMethod, PaidBy, Amount, PaymentStatus, TransactionCode, PaymentDate) VALUES
(1, 92001, 'e_wallet', 'sender', 100000.00, 'completed', 'TXN202611010001', '2026-11-01 08:05:00'),
(2, 92002, 'card', 'sender', 100000.00, 'completed', 'TXN202611010002', '2026-11-01 08:10:00'),
(3, 92003, 'cash', 'recipient', 100000.00, 'completed', 'TXN202611010003', '2026-11-01 10:15:00'),
(4, 92004, 'cash', 'sender', 100000.00, 'completed', 'TXN202611010004', '2026-11-01 08:00:00'),
(5, 92006, 'e_wallet', 'sender', 150000.00, 'completed', 'TXN202611020005', '2026-11-02 09:05:00'),
(6, 92007, 'card', 'sender', 80000.00, 'completed', 'TXN202611020006', '2026-11-02 10:10:00');

-- ============================================================================
-- GROUP C DATA: APPLIED_TO — Lê Tuấn (6 rows)
-- ============================================================================
INSERT INTO APPLIED_TO (OrderID, PromotionID, DiscountAmount, AppliedDate) VALUES
(92001, 1, 10000.00, '2026-11-01 08:00:00'),
(92002, 2, 25000.00, '2026-11-01 08:00:00'),
(92004, 3, 40000.00, '2026-11-01 08:00:00'),
(92006, 1, 15000.00, '2026-11-02 08:30:00'),
(92007, 2, 25000.00, '2026-11-02 09:15:00'),
(92008, 4, 30000.00, '2026-11-03 14:00:00');

-- ============================================================================
-- GROUP C DATA: POINT_TRANSACTION — Lê Tuấn (7 rows)
-- ============================================================================
INSERT INTO POINT_TRANSACTION (PointTransactionID, CustomerID, OrderID, PointAmount, TransactionType, TransactionDate, Description) VALUES
(1, 6, 92006, 50, 'earn', '2026-11-02 11:35:00', 'Points earned for completing order 92006'),
(2, 6, NULL, -20, 'redeem', '2026-11-02 15:00:00', 'Points redeemed for discount voucher'),
(3, 7, 92007, 30, 'earn', '2026-11-02 13:50:00', 'Points earned for completing order 92007'),
(4, 9, 92008, 100, 'earn', '2026-11-03 16:05:00', 'Points earned for completing order 92008'),
(5, 9, NULL, -50, 'redeem', '2026-11-03 18:00:00', 'Points redeemed for shopping discount'),
(6, 11, 92009, 40, 'earn', '2026-11-04 10:05:00', 'Points earned for completing order 92009'),
(7, 12, 92010, 25, 'earn', '2026-11-04 15:35:00', 'Points earned for completing order 92010');

-- ============================================================================
-- GROUP C DATA: FEEDBACK — Lê Tuấn (6 rows)
-- Trigger trg_feedback_after_insert updates SHIPPER.AverageRating automatically!
-- ============================================================================
INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType) VALUES
(1, 92004, 91004, 16, 5, 'Fast and very careful delivery, polite shipper!', '2026-11-01 11:30:00', 'customer'),
(2, 92004, 91004, 16, 5, 'Friendly customer, quick handover.', '2026-11-01 11:35:00', 'shipper'),
(3, 92006, 6, 17, 4, 'On-time delivery, friendly demeanor.', '2026-11-02 12:00:00', 'customer'),
(4, 92007, 7, 18, 5, 'Excellent service, handled fragile goods safely.', '2026-11-02 14:00:00', 'customer'),
(5, 92008, 9, 19, 4, 'Great delivery experience, will order again.', '2026-11-03 16:30:00', 'customer'),
(6, 92009, 11, 21, 5, 'Super prompt delivery, very professional.', '2026-11-04 10:15:00', 'customer');

-- ============================================================================
-- GROUP C DATA: SHIPPER_EARNING — Lê Tuấn (6 rows)
-- NetEarning is automatically computed as DeliveryFee - PlatformCommission.
-- ============================================================================
INSERT INTO SHIPPER_EARNING (EarningID, ShipperID, OrderID, DeliveryFee, PlatformCommission, EarningDate, PayoutStatus, PayoutDate) VALUES
(1, 16, 92004, 100000.00, 20000.00, '2026-11-01 11:00:00', 'paid', '2026-11-01 18:00:00'),
(2, 17, 92006, 150000.00, 30000.00, '2026-11-02 11:30:00', 'paid', '2026-11-02 18:00:00'),
(3, 18, 92007, 80000.00, 16000.00, '2026-11-02 13:45:00', 'paid', '2026-11-02 18:00:00'),
(4, 19, 92008, 120000.00, 24000.00, '2026-11-03 16:00:00', 'pending', NULL),
(5, 21, 92009, 200000.00, 40000.00, '2026-11-04 10:00:00', 'pending', NULL),
(6, 17, 92010, 180000.00, 36000.00, '2026-11-04 15:30:00', 'paid', '2026-11-04 19:00:00');

-- Verification of row counts for Group B:
SELECT COUNT(*) AS DeliveryOrderCount FROM DELIVERY_ORDER;
SELECT COUNT(*) AS OrderStatusLogCount FROM ORDER_STATUS_LOG;

-- Verification of row counts for Group C (Lê Tuấn - all >= 5 rows):
SELECT 'PROMOTION' AS TableName, COUNT(*) AS Total FROM PROMOTION
UNION ALL SELECT 'PAYMENT', COUNT(*) FROM PAYMENT
UNION ALL SELECT 'APPLIED_TO', COUNT(*) FROM APPLIED_TO
UNION ALL SELECT 'POINT_TRANSACTION', COUNT(*) FROM POINT_TRANSACTION
UNION ALL SELECT 'FEEDBACK', COUNT(*) FROM FEEDBACK
UNION ALL SELECT 'SHIPPER_EARNING', COUNT(*) FROM SHIPPER_EARNING;
