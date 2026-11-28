-- ============================================================================
-- 02_sample_data.sql | Integrated sample dataset for all 16 tables
-- Provides related customer, admin, shipper, delivery and reporting records.
-- ============================================================================
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
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
-- USER (28 rows). ID scheme: customer 91001-91010, admin 91101-91105,
-- shipper 91201-91210, role-less candidates 91301-91303.
INSERT INTO `USER` (UserID, Email, PhoneNumber, PasswordHash, AccountStatus, CreatedDate, DateOfBirth, Gender, FirstName, LastName) VALUES
-- Customers
(91001, 'lan.nguyen@mail.com', '0912000006', SHA2('Password@123', 256), 'active', '2025-01-05', '1995-03-18', 'female', 'Lan', 'Nguyễn Thị'),
(91002, 'hung.vo@mail.com', '0912000007', SHA2('Password@123', 256), 'active', '2025-01-12', '1990-08-25', 'male', 'Hùng', 'Võ Mạnh'),
(91003, 'mai.dang@mail.com', '0912000008', SHA2('Password@123', 256), 'active', '2025-02-03', '1998-12-02', 'female', 'Mai', 'Đặng Thị'),
(91004, 'tuan.bui@mail.com', '0912000009', SHA2('Password@123', 256), 'active', '2025-02-20', '1988-06-09', 'male', 'Tuấn', 'Bùi Anh'),
(91005, 'hoa.ngo@mail.com', '0912000010', SHA2('Password@123', 256), 'active', '2025-03-14', '2001-01-27', 'female', 'Hoa', 'Ngô Thị'),
(91006, 'nam.do@mail.com', '0912000011', SHA2('Password@123', 256), 'active', '2025-04-02', '1993-10-11', 'male', 'Nam', 'Đỗ Hoàng'),
(91007, 'thao.vu@mail.com', '0912000012', SHA2('Password@123', 256), 'active', '2025-05-19', '1997-04-30', 'female', 'Thảo', 'Vũ Phương'),
(91008, 'long.dinh@mail.com', '0912000013', SHA2('Password@123', 256), 'active', '2025-06-08', '2003-09-15', 'male', 'Long', 'Đinh Thanh'),
(91009, 'yen.truong@mail.com', '0912000014', SHA2('Password@123', 256), 'suspended', '2025-07-21', '1994-02-08', 'female', 'Yến', 'Trương Hải'),
(91010, 'quang.ly@mail.com', '0912000015', SHA2('Password@123', 256), 'closed', '2025-08-30', '1989-12-19', 'male', 'Quang', 'Lý Minh'),
-- Admins
(91101, 'an.nguyen@parceldelivery.vn', '0901000001', SHA2('Password@123', 256), 'active', '2024-01-10', '1980-05-12', 'male', 'An', 'Nguyễn Văn'),
(91102, 'binh.tran@parceldelivery.vn', '0901000002', SHA2('Password@123', 256), 'active', '2024-02-15', '1985-09-03', 'female', 'Bình', 'Trần Thị'),
(91103, 'cuong.le@parceldelivery.vn', '0901000003', SHA2('Password@123', 256), 'active', '2024-03-01', '1983-11-21', 'male', 'Cường', 'Lê Quốc'),
(91104, 'dung.pham@parceldelivery.vn', '0901000004', SHA2('Password@123', 256), 'active', '2024-06-20', '1990-02-14', 'female', 'Dung', 'Phạm Thùy'),
(91105, 'khang.hoang@parceldelivery.vn', '0901000005', SHA2('Password@123', 256), 'suspended', '2024-08-05', '1992-07-30', 'male', 'Khang', 'Hoàng Gia'),
-- Shippers
(91201, 'phuc.nguyen@mail.com', '0971000016', SHA2('Password@123', 256), 'active', '2025-01-08', '1995-04-10', 'male', 'Phúc', 'Nguyễn Hoàng'),
(91202, 'tai.tran@mail.com', '0971000017', SHA2('Password@123', 256), 'active', '2025-01-20', '1992-09-23', 'male', 'Tài', 'Trần Đức'),
(91203, 'ngoc.le@mail.com', '0971000018', SHA2('Password@123', 256), 'active', '2025-02-10', '1997-06-05', 'female', 'Ngọc', 'Lê Bảo'),
(91204, 'son.pham@mail.com', '0971000019', SHA2('Password@123', 256), 'active', '2025-03-03', '1994-01-17', 'male', 'Sơn', 'Phạm Trường'),
(91205, 'trang.vu@mail.com', '0971000020', SHA2('Password@123', 256), 'active', '2025-03-25', '1999-11-28', 'female', 'Trang', 'Vũ Thu'),
(91206, 'khoa.dang@mail.com', '0971000021', SHA2('Password@123', 256), 'active', '2025-04-12', '1991-07-14', 'male', 'Khoa', 'Đặng Anh'),
(91207, 'huy.bui@mail.com', '0971000022', SHA2('Password@123', 256), 'active', '2025-05-05', '2000-03-02', 'male', 'Huy', 'Bùi Quang'),
(91208, 'linh.ho@mail.com', '0971000023', SHA2('Password@123', 256), 'active', '2025-06-01', '1996-08-19', 'female', 'Linh', 'Hồ Thùy'),
(91209, 'dat.truong@mail.com', '0971000024', SHA2('Password@123', 256), 'suspended', '2025-06-18', '1993-05-26', 'male', 'Đạt', 'Trương Tiến'),
(91210, 'hieu.ly@mail.com', '0971000025', SHA2('Password@123', 256), 'closed', '2025-07-02', '1990-10-08', 'male', 'Hiếu', 'Lý Trung'),
-- Role-less candidates (for sp_InsertShipper demo)
(91301, 'khoa.nguyen@mail.com', '0981000026', SHA2('Password@123', 256), 'active', '2026-10-01', '1998-06-15', 'male', 'Khoa', 'Nguyễn Đăng'),
(91302, 'bao.tran@mail.com', '0981000027', SHA2('Password@123', 256), 'active', '2026-10-15', '2010-03-15', 'male', 'Bảo', 'Trần Gia'),
(91303, 'vy.le@mail.com', '0981000028', SHA2('Password@123', 256), 'suspended', '2026-09-20', '1996-12-01', 'female', 'Vy', 'Lê Khánh');

-- ADMIN (5 rows). Supervisors inserted before subordinates; admin 91105 is suspended.
INSERT INTO ADMIN (UserID, EmployeeCode, Department, AccessLevel, HireDate, Supervisor_ID) VALUES
(91101, 'AD001', 'Operations', 3, '2024-01-10', NULL),
(91102, 'AD002', 'Customer Support', 2, '2024-02-15', 91101),
(91103, 'AD003', 'Finance', 2, '2024-03-01', 91101),
(91104, 'AD004', 'Technical', 1, '2024-06-20', 91102),
(91105, 'AD005', 'Human Resources', 1, '2024-08-05', 91103);

-- CUSTOMER (10 rows). 91009 is suspended, 91010 is closed.
-- NOTE: LoyaltyPoint must equal earned minus redeemed points in POINT_TRANSACTION.
INSERT INTO CUSTOMER (UserID, LoyaltyPoint) VALUES
(91001, 0),
(91002, 0),
(91003, 0),
(91004, 0),
(91005, 0),
(91006, 30),
(91007, 30),
(91008, 50),
(91009, 40),
(91010, 25);

-- SHIPPER (10 rows). 91209 is suspended and 91210 is closed, so both are offline.
INSERT INTO SHIPPER (UserID, NationalIdentificationNumber, AvailabilityStatus, JoinDate, ManagedByAdminID) VALUES
(91201, '079095123401', 'available', '2025-01-15', 91101),
(91202, '001092234502', 'available', '2025-02-01', 91101),
(91203, '048197345603', 'busy',      '2025-02-20', 91102),
(91204, '092094456704', 'available', '2025-03-10', 91102),
(91205, '075199567805', 'offline',   '2025-04-01', 91103),
(91206, '074091678906', 'busy',      '2025-04-20', 91103),
(91207, '031200789007', 'available', '2025-05-12', 91104),
(91208, '056196890108', 'offline',   '2025-06-10', 91104),
(91209, '087093901209', 'offline',   '2025-06-25', 91102),
(91210, '038090012310', 'offline',   '2025-07-09', 91103);

-- SHIPPER_LICENSE (11 rows). Shipper 91206 holds 2 licences; licence of 91204 is expired.
INSERT INTO SHIPPER_LICENSE (ShipperID, LicenseNumber, LicenseType) VALUES
(91201, '790116000001', 'A1'),
(91202, '790117000002', 'A2'),
(91203, '790118000003', 'A1'),
(91204, '790119000004', 'A1'),
(91205, '790120000005', 'A2'),
(91206, '790121000006', 'B1'),
(91206, '790121000016', 'A1'),
(91207, '790122000007', 'B2'),
(91208, '790123000008', 'B2'),
(91209, '790124000009', 'C'),
(91210, '790125000010', 'A1');

-- VEHICLE (9 rows). One vehicle per shipper; shipper 91210 has no vehicle.
INSERT INTO VEHICLE (VehicleID, ShipperID, Brand, Model, LicensePlate, Color, MaximumLoad, VehicleType) VALUES
(1, 91201, 'Honda', 'Wave Alpha', '59X1-234.56', 'Red', 40, 'motorbike'),
(2, 91202, 'Yamaha', 'Exciter', '29B1-345.67', 'Black', 50, 'motorbike'),
(3, 91203, 'Honda', 'Air Blade', '43E1-456.78', 'White', 45, 'motorbike'),
(4, 91204, 'Honda', 'Vision', '65G1-567.89', 'Blue', 40, 'motorbike'),
(5, 91205, 'Yamaha', 'Sirius', '60B1-678.90', 'Silver', 40, 'motorbike'),
(6, 91206, 'Toyota', 'Vios', '51A-123.45', 'White', 400, 'car'),
(7, 91207, 'Kia', 'Morning', '30E-456.78', 'Silver', 350, 'car'),
(8, 91208, 'Hyundai', 'Solati', '51C-789.01', 'White', 900, 'van'),
(9, 91209, 'Isuzu', 'QKR', '29C-890.12', 'Blue', 1900, 'truck');

-- Row-count check for this group (each must be >= 5):
SELECT 'USER' AS TableName, COUNT(*) AS Total FROM `USER`
UNION ALL SELECT 'ADMIN', COUNT(*) FROM ADMIN
UNION ALL SELECT 'CUSTOMER', COUNT(*) FROM CUSTOMER
UNION ALL SELECT 'SHIPPER', COUNT(*) FROM SHIPPER
UNION ALL SELECT 'SHIPPER_LICENSE', COUNT(*) FROM SHIPPER_LICENSE
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
(92006,91006,'45 Le Duan','District 1','Ho Chi Minh City','12 Vo Van Ngan','Thu Duc City','Ho Chi Minh City','2026-11-02 08:30:00','Express','Sender 6','0901234506','Receiver 6','0911234506',12.00,0,'completed','Delivered on time','2026-11-02 11:30:00',NULL),
(92007,91007,'78 Tran Hung Dao','District 5','Ho Chi Minh City','99 Cong Hoa','Tan Binh District','Ho Chi Minh City','2026-11-02 09:15:00','Standard','Sender 7','0901234507','Receiver 7','0911234507',8.20,50000,'completed','Delivered safely','2026-11-02 13:45:00',NULL),
(92008,91008,'101 Cach Mang Thang 8','District 3','Ho Chi Minh City','55 Nguyen Thi Minh Khai','District 1','Ho Chi Minh City','2026-11-03 14:00:00','Standard','Sender 8','0901234508','Receiver 8','0911234508',4.50,200000,'completed','Fragile item delivered','2026-11-03 16:00:00',NULL),
(92009,91009,'202 Hoang Van Thu','Phu Nhuan District','Ho Chi Minh City','15 Ba Huyen Thanh Quan','District 3','Ho Chi Minh City','2026-11-04 08:00:00','Express','Sender 9','0901234509','Receiver 9','0911234509',6.00,0,'completed','Fast delivery completed','2026-11-04 10:00:00',NULL),
(92010,91010,'88 Nguyen Trai','District 5','Ho Chi Minh City','33 Dien Bien Phu','Binh Thanh District','Ho Chi Minh City','2026-11-04 13:00:00','Standard','Sender 10','0901234510','Receiver 10','0911234510',7.50,150000,'completed','Delivered to recipient','2026-11-04 15:30:00',NULL);

-- 9) PACKAGE — at least one package for each seeded delivery order.
INSERT INTO `PACKAGE` (PackageID, OrderID, PackageDescription, PackageCategory, Weight, Length, Width, Height, DeclaredValue, IsFragile) VALUES
(1, 92001, 'Small document parcel', 'Documents', 0.50, 22, 16, 2, 100000, FALSE),
(2, 92002, 'Clothing package', 'Clothing', 1.20, 30, 25, 10, 350000, FALSE),
(3, 92003, 'Kitchen appliance', 'Electronics', 4.50, 40, 35, 25, 1800000, TRUE),
(4, 92004, 'Glassware set', 'Household', 3.20, 35, 30, 22, 900000, TRUE),
(5, 92005, 'Books', 'Books', 2.00, 28, 20, 12, 250000, FALSE),
(6, 92006, 'Computer accessories', 'Electronics', 1.80, 32, 24, 8, 1200000, TRUE),
(7, 92007, 'Shoes', 'Fashion', 1.10, 34, 22, 13, 650000, FALSE),
(8, 92008, 'Cosmetics box', 'Personal care', 0.90, 25, 18, 12, 450000, TRUE),
(9, 92009, 'Office supplies', 'Stationery', 2.40, 36, 28, 15, 300000, FALSE),
(10, 92010, 'Sports equipment', 'Sports', 5.00, 50, 30, 20, 1500000, FALSE);

-- 10) DELIVERY_ASSIGNMENT — one completed/active assignment per applicable order.
-- VehicleID belongs to the shipper recorded in each row.
INSERT INTO DELIVERY_ASSIGNMENT (OrderID, AssignmentNo, ShipperID, AssignedDate, AcceptedDate, CompleteDate, AssignmentStatus, RejectionReason) VALUES
(92002, 1, 91201, '2026-11-01 08:45:00', '2026-11-01 09:00:00', NULL, 'accepted', NULL),
(92003, 1, 91203, '2026-11-01 09:30:00', '2026-11-01 09:45:00', NULL, 'accepted', NULL),
(92004, 1, 91201, '2026-11-01 09:00:00', '2026-11-01 09:10:00', '2026-11-01 11:00:00', 'completed', NULL),
(92006, 1, 91202, '2026-11-02 09:00:00', '2026-11-02 09:10:00', '2026-11-02 11:30:00', 'completed', NULL),
(92007, 1, 91203, '2026-11-02 10:00:00', '2026-11-02 10:10:00', '2026-11-02 13:45:00', 'completed', NULL),
(92008, 1, 91204, '2026-11-03 14:20:00', '2026-11-03 14:30:00', '2026-11-03 16:00:00', 'completed', NULL),
(92009, 1, 91206, '2026-11-04 08:20:00', '2026-11-04 08:30:00', '2026-11-04 10:00:00', 'completed', NULL),
(92010, 1, 91202, '2026-11-04 13:20:00', '2026-11-04 13:30:00', '2026-11-04 15:30:00', 'completed', NULL);
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
(93013,92006,91006,'placed','2026-11-02 08:30:00','Order placed'),
(93014,92006,91202,'completed','2026-11-02 11:30:00','Order completed'),
(93015,92007,91007,'placed','2026-11-02 09:15:00','Order placed'),
(93016,92007,91203,'completed','2026-11-02 13:45:00','Order completed'),
(93017,92008,91008,'placed','2026-11-03 14:00:00','Order placed'),
(93018,92008,91204,'completed','2026-11-03 16:00:00','Order completed'),
(93019,92009,91009,'placed','2026-11-04 08:00:00','Order placed'),
(93020,92009,91206,'completed','2026-11-04 10:00:00','Order completed'),
(93021,92010,91010,'placed','2026-11-04 13:00:00','Order placed'),
(93022,92010,91202,'completed','2026-11-04 15:30:00','Order completed');

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
(1, 91006, 92006, 50, 'earn', '2026-11-02 11:35:00', 'Points earned for completing order 92006'),
(2, 91006, NULL, -20, 'redeem', '2026-11-02 15:00:00', 'Points redeemed for discount voucher'),
(3, 91007, 92007, 30, 'earn', '2026-11-02 13:50:00', 'Points earned for completing order 92007'),
(4, 91008, 92008, 100, 'earn', '2026-11-03 16:05:00', 'Points earned for completing order 92008'),
(5, 91008, NULL, -50, 'redeem', '2026-11-03 18:00:00', 'Points redeemed for shopping discount'),
(6, 91009, 92009, 40, 'earn', '2026-11-04 10:05:00', 'Points earned for completing order 92009'),
(7, 91010, 92010, 25, 'earn', '2026-11-04 15:35:00', 'Points earned for completing order 92010');

-- ============================================================================
-- GROUP C DATA: FEEDBACK — Lê Tuấn (6 rows)
-- Trigger trg_feedback_after_insert updates SHIPPER.AverageRating automatically!
-- ============================================================================
INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType) VALUES
(1, 92004, 91004, 91201, 5, 'Fast and very careful delivery, polite shipper!', '2026-11-01 11:30:00', 'customer'),
(2, 92004, 91004, 91201, 5, 'Friendly customer, quick handover.', '2026-11-01 11:35:00', 'shipper'),
(3, 92006, 91006, 91202, 4, 'On-time delivery, friendly demeanor.', '2026-11-02 12:00:00', 'customer'),
(4, 92007, 91007, 91203, 5, 'Excellent service, handled fragile goods safely.', '2026-11-02 14:00:00', 'customer'),
(5, 92008, 91008, 91204, 4, 'Great delivery experience, will order again.', '2026-11-03 16:30:00', 'customer'),
(6, 92009, 91009, 91206, 5, 'Super prompt delivery, very professional.', '2026-11-04 10:15:00', 'customer');

-- ============================================================================
-- GROUP C DATA: SHIPPER_EARNING — Lê Tuấn (6 rows)
-- NetEarning is automatically computed as DeliveryFee - PlatformCommission.
-- ============================================================================
INSERT INTO SHIPPER_EARNING (EarningID, ShipperID, OrderID, DeliveryFee, PlatformCommission, EarningDate, PayoutStatus, PayoutDate) VALUES
(1, 91201, 92004, 100000.00, 20000.00, '2026-11-01 11:00:00', 'paid', '2026-11-01 18:00:00'),
(2, 91202, 92006, 150000.00, 30000.00, '2026-11-02 11:30:00', 'paid', '2026-11-02 18:00:00'),
(3, 91203, 92007, 80000.00, 16000.00, '2026-11-02 13:45:00', 'paid', '2026-11-02 18:00:00'),
(4, 91204, 92008, 120000.00, 24000.00, '2026-11-03 16:00:00', 'pending', NULL),
(5, 91206, 92009, 200000.00, 40000.00, '2026-11-04 10:00:00', 'pending', NULL),
(6, 91202, 92010, 180000.00, 36000.00, '2026-11-04 15:30:00', 'paid', '2026-11-04 19:00:00');

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
