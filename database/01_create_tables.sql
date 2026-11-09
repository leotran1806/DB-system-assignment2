-- ============================================================================
-- 01_create_tables.sql | A2 - Section 1.1 (2 points)
-- DBMS: MySQL 8.0.16+
--
-- STARTER FILE: this file intentionally contains TODO instructions, not the
-- completed CREATE TABLE implementation. Fill every table below before running
-- 02_sample_data.sql or connecting the application to the database.
--
-- Important: unlike the original project script, this starter does NOT DROP
-- an existing database. It is safe to run repeatedly before you add your DDL.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS parcel_delivery
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE parcel_delivery;

-- ---------------------------------------------------------------------------
-- DDL checklist
-- Create ALL 16 relational tables. For every table, define:
--   [ ] appropriate data types and NULL/NOT NULL/default values
--   [ ] PRIMARY KEY
--   [ ] FOREIGN KEY constraints and suitable ON DELETE/ON UPDATE rules
--   [ ] UNIQUE constraints for candidate keys
--   [ ] CHECK constraints for row-level rules that can be checked in a row
--   [ ] indexes for frequently joined / searched foreign-key columns
--
-- A2 note: if a constraint can be expressed with PRIMARY KEY, FOREIGN KEY,
-- UNIQUE, NOT NULL, DEFAULT or CHECK in CREATE TABLE, do NOT implement it as
-- a trigger. Use triggers only for cross-row / cross-table business rules.
-- ---------------------------------------------------------------------------

-- 1) USER
-- TODO: CREATE TABLE `USER`.
-- Required attributes from A1:
--   UserID (PK, auto number), Email, PhoneNumber, PasswordHash, AccountStatus,
--   CreatedDate, DateOfBirth, Gender, FirstName, LastName.
-- Constraints to consider:
--   * Email UNIQUE and valid email format (CHECK where supported).
--   * PhoneNumber UNIQUE and 10-digit Vietnamese mobile format from A1.
--   * AccountStatus: active / suspended / closed.
--   * Gender: male / female / other.
--   * FirstName and LastName must not be blank.

-- 2) ADMIN
-- TODO: CREATE TABLE ADMIN.
-- Required attributes: UserID (PK and FK -> USER), EmployeeCode (UNIQUE),
-- Department, AccessLevel, HireDate, Supervisor_ID (self-referencing FK -> ADMIN).
-- Constraints: AccessLevel 1..3; an admin cannot supervise themself.

-- 3) CUSTOMER
-- TODO: CREATE TABLE CUSTOMER.
-- Required attributes: UserID (PK and FK -> USER), LoyaltyPoint.
-- Constraint: LoyaltyPoint >= 0.

-- 4) SHIPPER
-- TODO: CREATE TABLE SHIPPER.
-- Required attributes: UserID (PK and FK -> USER),
-- NationalIdentificationNumber (UNIQUE), AvailabilityStatus, JoinDate,
-- ManagedByAdminID (nullable FK -> ADMIN).
-- A1 derived attribute selected for A2 trigger 2.2.2: AverageRating.
-- Store AverageRating only if the team intends to maintain it with triggers.
-- AvailabilityStatus: available / busy / offline.
-- NationalIdentificationNumber: 9 or 12 digits.

-- 5) SHIPPER_LICENSE
-- TODO: CREATE TABLE SHIPPER_LICENSE.
-- Required attributes: ShipperID (FK -> SHIPPER), LicenseNumber, LicenseType.
-- Use a composite PK appropriate to A1 (ShipperID + LicenseNumber).
-- LicenseType values in the team's A1 model: A1 / A2 / B1 / B2 / C.

-- 6) VEHICLE
-- TODO: CREATE TABLE VEHICLE.
-- Required attributes: VehicleID (PK), ShipperID (FK -> SHIPPER), Brand, Model,
-- LicensePlate, Color, MaximumLoad, VehicleType.
-- A1 relationship: one vehicle per shipper; make ShipperID UNIQUE.
-- Constraints: MaximumLoad > 0; LicensePlate UNIQUE and format-validated.
-- VehicleType: motorbike / car / van / truck.

-- 7) DELIVERY_ORDER — Duy
-- Dependencies: CUSTOMER.UserID and USER.UserID must be signed INT.
CREATE TABLE DELIVERY_ORDER (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    PickupAddressDetail VARCHAR(255) NOT NULL,
    PickupDistrict VARCHAR(100) NOT NULL,
    PickupProvinceCity VARCHAR(100) NOT NULL,
    DeliveryAddressDetail VARCHAR(255) NOT NULL,
    DeliveryDistrict VARCHAR(100) NOT NULL,
    DeliveryProvinceCity VARCHAR(100) NOT NULL,
    CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ServiceType VARCHAR(30) NOT NULL,
    PickupContactName VARCHAR(100) NOT NULL,
    PickupContactPhone VARCHAR(20) NOT NULL,
    DeliveryContactName VARCHAR(100) NOT NULL,
    DeliveryContactPhone VARCHAR(20) NOT NULL,
    Distance DECIMAL(10,2) NOT NULL,
    CODAmount DECIMAL(15,2) NOT NULL DEFAULT 0,
    OrderStatus VARCHAR(20) NOT NULL DEFAULT 'placed',
    Note VARCHAR(500),
    CompleteDate DATETIME,
    CancellationReason VARCHAR(500),
    CONSTRAINT fk_order_customer FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(UserID),
    CONSTRAINT ck_order_distance CHECK (Distance >= 0),
    CONSTRAINT ck_order_cod CHECK (CODAmount >= 0),
    CONSTRAINT ck_order_status CHECK (OrderStatus IN ('placed','accepted','delivering','completed','cancelled')),
    CONSTRAINT ck_order_completion CHECK (
        (OrderStatus = 'completed' AND CompleteDate IS NOT NULL AND CompleteDate >= CreatedDate)
        OR (OrderStatus <> 'completed' AND CompleteDate IS NULL)),
    CONSTRAINT ck_order_cancel_reason CHECK (
        OrderStatus <> 'cancelled' OR
        (CancellationReason IS NOT NULL AND CHAR_LENGTH(TRIM(CancellationReason)) > 0)),
    INDEX ix_order_status_created (OrderStatus, CreatedDate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8) PACKAGE
-- TODO: CREATE TABLE `PACKAGE`.
-- Required attributes: PackageID (PK), OrderID (FK -> DELIVERY_ORDER),
-- PackageDescription, PackageCategory, Weight, Length, Width, Height,
-- DeclaredValue, IsFragile.
-- Constraints: dimensions/weight/declared value must not be negative; A1 says
-- every order contains at least one package (cross-row rule, not simple CHECK).

-- 9) DELIVERY_ASSIGNMENT (weak entity)
-- TODO: CREATE TABLE DELIVERY_ASSIGNMENT.
-- Required attributes: OrderID, AssignmentNo, ShipperID, VehicleID, AssignedDate,
-- AcceptedDate, CompleteDate, AssignmentStatus, RejectionReason.
-- Use composite PK (OrderID, AssignmentNo), with FKs to DELIVERY_ORDER,
-- SHIPPER and VEHICLE. Consider date-order CHECK constraints:
--   AcceptedDate >= AssignedDate; CompleteDate >= AcceptedDate.
-- AssignmentStatus values must follow A1.

-- 10) ORDER_STATUS_LOG — Duy
CREATE TABLE ORDER_STATUS_LOG (
    StatusLogID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ChangedByUserID INT NOT NULL,
    Status VARCHAR(20) NOT NULL,
    ChangedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Note VARCHAR(500),
    CONSTRAINT fk_status_order FOREIGN KEY (OrderID) REFERENCES DELIVERY_ORDER(OrderID),
    CONSTRAINT fk_status_user FOREIGN KEY (ChangedByUserID) REFERENCES `USER`(UserID),
    CONSTRAINT ck_log_status CHECK (Status IN ('placed','accepted','delivering','completed','cancelled')),
    INDEX ix_log_order_date (OrderID, ChangedDate, StatusLogID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11) PAYMENT
-- TODO: CREATE TABLE PAYMENT.
-- Required attributes: PaymentID (PK), OrderID (UNIQUE FK -> DELIVERY_ORDER),
-- PaymentMethod, PaidBy, Amount, PaymentStatus, TransactionCode, PaymentDate.
-- A1 stores successful payment records; choose suitable checks for amount,
-- method, payer and status.

-- 12) PROMOTION
-- TODO: CREATE TABLE PROMOTION.
-- Required attributes: PromotionID (PK), PromotionCode (UNIQUE), PromotionName,
-- Description, DiscountType, DiscountValue, MaximumDiscount, MinimumOrderValue,
-- StartDate, EndDate, UsageLimit, PromotionStatus.
-- Checks: DiscountValue > 0; percentage <= 100; MaximumDiscount >= 0 when set;
-- MinimumOrderValue >= 0; EndDate >= StartDate; UsageLimit > 0.

-- 13) APPLIED_TO (associative table for DELIVERY_ORDER <-> PROMOTION)
-- TODO: CREATE TABLE APPLIED_TO.
-- Required attributes: OrderID (FK -> DELIVERY_ORDER), PromotionID (FK -> PROMOTION),
-- DiscountAmount, AppliedDate. Use composite PK (OrderID, PromotionID).
-- Constraint: DiscountAmount >= 0. More detailed discount validity, promotion
-- period and usage count require cross-table validation (see 2.2 trigger choice
-- or another suitable database mechanism).

-- 14) POINT_TRANSACTION
-- TODO: CREATE TABLE POINT_TRANSACTION.
-- Required attributes: PointTransactionID (PK), CustomerID (FK -> CUSTOMER),
-- OrderID (nullable UNIQUE FK -> DELIVERY_ORDER if matching A1), PointAmount,
-- TransactionType, TransactionDate, Description.
-- A1 requires the customer balance to equal earned points minus redeemed points;
-- a deduction must not make the balance negative.

-- 15) FEEDBACK
-- TODO: CREATE TABLE FEEDBACK.
-- Required attributes: FeedbackID (PK), OrderID (FK -> DELIVERY_ORDER),
-- CustomerID (FK -> CUSTOMER), ShipperID (FK -> SHIPPER), Rating, Comment,
-- CreatedDate, FeedbackType.
-- Constraints: Rating is an integer 1..5. Enforce at most one feedback per party
-- per order (use a suitable UNIQUE key or equivalent design based on FeedbackType).
-- Only completed orders can receive feedback (cross-table rule).

-- 16) SHIPPER_EARNING
-- TODO: CREATE TABLE SHIPPER_EARNING.
-- Required attributes: EarningID (PK), ShipperID (FK -> SHIPPER),
-- OrderID (UNIQUE FK -> DELIVERY_ORDER), DeliveryFee, PlatformCommission,
-- NetEarning (derived or stored), EarningDate, PayoutStatus, PayoutDate.
-- Constraints: PlatformCommission between 0 and DeliveryFee; NetEarning equals
-- DeliveryFee - PlatformCommission; paid payout requires PayoutDate >= EarningDate.
-- Historical earning values must not change when a commission policy changes.

-- ---------------------------------------------------------------------------
-- A1 semantic constraints to map to CHECK / FK / UNIQUE / TRIGGER / procedure:
-- 1. Suspended/closed USER cannot create orders or accept assignments; shipper
--    can accept only while AvailabilityStatus='available'.
-- 2. Assignment vehicle belongs to assigned shipper, matches ServiceType and
--    is allowed by one of the shipper's license types.
-- 3. Sum of package weights for an order <= MaximumLoad of assigned vehicle.
-- 4. An order has at most one active (accepted) assignment at a time.
-- 5. AcceptedDate >= AssignedDate; CompleteDate >= AcceptedDate.
-- 6. Order can complete only after successful assignment completion; completed
--    cannot move backwards; cancelled order needs CancellationReason.
-- 7. Current order status equals latest ORDER_STATUS_LOG status.
-- 8. Promotion must be active/in period, meet minimum order value, and stay
--    within usage limit.
-- 9. Per-promotion and total discount calculations must be valid and bounded.
-- 10. DeliveryFee follows the team's pricing rule; FinalPrice = Fee - Discount.
-- 11. Earning only after successful delivery and belongs to completing shipper.
-- 12. Paid earning requires valid payout date; preserve historical commission.
-- 13. Feedback only after delivery, by the correct party, at most once per party.
-- 14. SHIPPER.AverageRating = average of customer-to-shipper feedback only.
-- 15. CUSTOMER.LoyaltyPoint = earned minus redeemed point transactions; balance
--     must never become negative.
-- ---------------------------------------------------------------------------
