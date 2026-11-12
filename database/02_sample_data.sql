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

-- SHIPPER_LICENSE (11 rows). Shipper 21 holds 2 licences; licence of shipper 19 is expired (demo case).
INSERT INTO SHIPPER_LICENSE (ShipperID, LicenseNumber, LicenseType, IssueDate, ExpiryDate) VALUES
(16, '790116000001', 'A1', '2021-05-10', '2031-05-10'),
(17, '790117000002', 'A2', '2020-08-15', '2030-08-15'),
(18, '790118000003', 'A1', '2019-02-20', '2029-02-20'),
(19, '790119000004', 'A1', '2018-06-01', '2026-06-01'),
(20, '790120000005', 'A2', '2022-01-12', '2032-01-12'),
(21, '790121000006', 'B1', '2020-09-09', '2030-09-09'),
(21, '790121000016', 'A1', '2019-04-04', '2029-04-04'),
(22, '790122000007', 'B2', '2021-11-30', '2031-11-30'),
(23, '790123000008', 'B2', '2020-03-18', '2030-03-18'),
(24, '790124000009', 'C',  '2019-07-22', '2029-07-22'),
(25, '790125000010', 'A1', '2018-10-05', '2028-10-05');

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
UNION ALL SELECT 'SHIPPER_LICENSE', COUNT(*) FROM SHIPPER_LICENSE
UNION ALL SELECT 'VEHICLE', COUNT(*) FROM VEHICLE;

-- TODO 7: INSERT >= 5 PROMOTION rows.
--        Include percentage/fixed discounts, active/inactive/expired states,
--        valid date windows, minimum values and distinct usage limits.

-- 8: Duy — requires CUSTOMER IDs 91001..91005 from group A.
INSERT INTO DELIVERY_ORDER (OrderID, CustomerID, PickupAddressDetail, PickupDistrict, PickupProvinceCity, DeliveryAddressDetail, DeliveryDistrict, DeliveryProvinceCity, CreatedDate, ServiceType, PickupContactName, PickupContactPhone, DeliveryContactName, DeliveryContactPhone, Distance, CODAmount, OrderStatus, Note, CompleteDate, CancellationReason) VALUES
(92001,91001,'123 Nguyen Van Cu','District 5','Ho Chi Minh City','268 Ly Thuong Kiet','District 10','Ho Chi Minh City','2026-11-01 08:00:00','Standard','Sender 1','0901234501','Receiver 1','0911234501',5.50,100000,'placed','Demo order 1',NULL,NULL),
(92002,91002,'123 Nguyen Van Cu','District 5','Ho Chi Minh City','268 Ly Thuong Kiet','District 10','Ho Chi Minh City','2026-11-01 08:00:00','Standard','Sender 2','0901234502','Receiver 2','0911234502',5.50,100000,'accepted','Demo order 2',NULL,NULL),
(92003,91003,'123 Nguyen Van Cu','District 5','Ho Chi Minh City','268 Ly Thuong Kiet','District 10','Ho Chi Minh City','2026-11-01 08:00:00','Standard','Sender 3','0901234503','Receiver 3','0911234503',5.50,100000,'delivering','Demo order 3',NULL,NULL),
(92004,91004,'123 Nguyen Van Cu','District 5','Ho Chi Minh City','268 Ly Thuong Kiet','District 10','Ho Chi Minh City','2026-11-01 08:00:00','Standard','Sender 4','0901234504','Receiver 4','0911234504',5.50,100000,'completed','Demo order 4','2026-11-01 11:00:00',NULL),
(92005,91005,'123 Nguyen Van Cu','District 5','Ho Chi Minh City','268 Ly Thuong Kiet','District 10','Ho Chi Minh City','2026-11-01 08:00:00','Standard','Sender 5','0901234505','Receiver 5','0911234505',5.50,100000,'cancelled','Demo order 5',NULL,'Customer requested cancellation');

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
(93012,92005,91005,'cancelled','2026-11-01 09:00:00','Demo status history');

-- TODO 12: INSERT >= 5 PAYMENT rows.
--         Each OrderID must be unique if the one-payment-per-order rule is used.
--         Use values allowed by the CHECK constraints.
--
-- TODO 13: INSERT >= 5 APPLIED_TO rows.
--         Use existing orders/promotions. Discounts must be correct and total
--         discounts must not exceed DeliveryFee. Respect promotion validity.
--
-- TODO 14: INSERT >= 5 POINT_TRANSACTION rows.
--         Include both earn and redeem transactions; no resulting balance may
--         become negative. Link order IDs only when appropriate.
--
-- TODO 15: INSERT >= 5 FEEDBACK rows.
--         Use completed orders only; Rating must be integer 1..5. Include both
--         Customer-to-Shipper and Shipper-to-Customer feedback types.
--
-- TODO 16: INSERT >= 5 SHIPPER_EARNING rows.
--         Use completed orders and the shipper who completed each order.
--         NetEarning must equal DeliveryFee - PlatformCommission. Include paid
--         and pending payouts; paid rows need valid PayoutDate values.

-- TODO: after inserting all rows, write SELECT COUNT(*) checks for all 16
-- tables and verify every count is >= 5 before the presentation.

-- Duy: verify group B row counts (expected 5 orders, 12 status logs).
SELECT COUNT(*) AS DeliveryOrderCount FROM DELIVERY_ORDER;
SELECT COUNT(*) AS OrderStatusLogCount FROM ORDER_STATUS_LOG;
