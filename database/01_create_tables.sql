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
-- 1) USER
CREATE TABLE `USER` (
    UserID        INT          NOT NULL AUTO_INCREMENT,
    Email         VARCHAR(100) NOT NULL,
    PhoneNumber   VARCHAR(10)  NOT NULL,
    PasswordHash  VARCHAR(255) NOT NULL,
    AccountStatus VARCHAR(20)  NOT NULL DEFAULT 'active',
    CreatedDate   DATE         NOT NULL DEFAULT (CURRENT_DATE),
    DateOfBirth   DATE         NOT NULL,
    Gender        VARCHAR(10)  NOT NULL,
    FirstName     VARCHAR(50)  NOT NULL,
    LastName      VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_user PRIMARY KEY (UserID),
    CONSTRAINT uq_user_email UNIQUE (Email),
    CONSTRAINT uq_user_phone UNIQUE (PhoneNumber),
    CONSTRAINT chk_user_email
        CHECK (Email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_user_phone
        CHECK (PhoneNumber REGEXP '^0[0-9]{9}$'),
    CONSTRAINT chk_user_password CHECK (TRIM(PasswordHash) <> ''),
    CONSTRAINT chk_user_status
        CHECK (AccountStatus IN ('active', 'suspended', 'closed')),
    CONSTRAINT chk_user_gender CHECK (Gender IN ('male', 'female')),
    CONSTRAINT chk_user_firstname CHECK (TRIM(FirstName) <> ''),
    CONSTRAINT chk_user_lastname CHECK (TRIM(LastName) <> ''),
    CONSTRAINT chk_user_dob CHECK (DateOfBirth < CreatedDate)
) ENGINE = InnoDB;
 

-- 2) ADMIN
-- TODO: CREATE TABLE ADMIN.
-- Required attributes: UserID (PK and FK -> USER), EmployeeCode (UNIQUE),
-- Department, AccessLevel, HireDate, Supervisor_ID (self-referencing FK -> ADMIN).
-- Constraints: AccessLevel 1..3; an admin cannot supervise themself.
-- 2) ADMIN  
CREATE TABLE ADMIN (
    UserID        INT         NOT NULL,
    EmployeeCode  VARCHAR(20) NOT NULL,
    Department    VARCHAR(50) NOT NULL,
    AccessLevel   TINYINT     NOT NULL,
    HireDate      DATE        NOT NULL,
    Supervisor_ID INT         NULL,
    CONSTRAINT pk_admin PRIMARY KEY (UserID),
    CONSTRAINT uq_admin_employee_code UNIQUE (EmployeeCode),
    CONSTRAINT fk_admin_user FOREIGN KEY (UserID)
        REFERENCES `USER` (UserID) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_admin_supervisor FOREIGN KEY (Supervisor_ID)
        REFERENCES ADMIN (UserID) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_admin_code CHECK (TRIM(EmployeeCode) <> ''),
    CONSTRAINT chk_admin_department CHECK (TRIM(Department) <> ''),
    CONSTRAINT chk_admin_level CHECK (AccessLevel BETWEEN 1 AND 3),
    CONSTRAINT chk_admin_not_self_supervisor CHECK (Supervisor_ID IS NULL OR Supervisor_ID <> UserID),
    INDEX idx_admin_supervisor (Supervisor_ID)
) ENGINE = InnoDB;

-- 3) CUSTOMER
-- TODO: CREATE TABLE CUSTOMER.
-- Required attributes: UserID (PK and FK -> USER), LoyaltyPoint.
-- Constraint: LoyaltyPoint >= 0.
-- 3) CUSTOMER
CREATE TABLE CUSTOMER (
    UserID       INT NOT NULL,
    LoyaltyPoint INT NOT NULL DEFAULT 0,
    CONSTRAINT pk_customer PRIMARY KEY (UserID),
    CONSTRAINT fk_customer_user FOREIGN KEY (UserID)
        REFERENCES `USER` (UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_customer_point CHECK (LoyaltyPoint >= 0)
) ENGINE = InnoDB;
 

-- 4) SHIPPER
-- TODO: CREATE TABLE SHIPPER.
-- Required attributes: UserID (PK and FK -> USER),
-- NationalIdentificationNumber (UNIQUE), AvailabilityStatus, JoinDate,
-- ManagedByAdminID (nullable FK -> ADMIN).
-- A1 derived attribute selected for A2 trigger 2.2.2: AverageRating.
-- Store AverageRating only if the team intends to maintain it with triggers.
-- AvailabilityStatus: available / busy / offline.
-- NationalIdentificationNumber: 9 or 12 digits.
-- 4) SHIPPER
CREATE TABLE SHIPPER (
    UserID                       INT          NOT NULL,
    NationalIdentificationNumber VARCHAR(12)  NOT NULL,
    AvailabilityStatus           VARCHAR(20)  NOT NULL DEFAULT 'offline',
    JoinDate                     DATE         NOT NULL DEFAULT (CURRENT_DATE),
    ManagedByAdminID             INT          NOT NULL,
    AverageRating                DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_shipper PRIMARY KEY (UserID),
    CONSTRAINT uq_shipper_nin UNIQUE (NationalIdentificationNumber),
    CONSTRAINT fk_shipper_user FOREIGN KEY (UserID)
        REFERENCES `USER` (UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_shipper_admin FOREIGN KEY (ManagedByAdminID)
        REFERENCES ADMIN (UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_shipper_nin
        CHECK (NationalIdentificationNumber REGEXP '^0[0-9]{11}$'),
    CONSTRAINT chk_shipper_availability
        CHECK (AvailabilityStatus IN ('available', 'busy', 'offline')),
    CONSTRAINT chk_shipper_rating CHECK (AverageRating BETWEEN 0 AND 5),
    INDEX idx_shipper_availability (AvailabilityStatus)
) ENGINE = InnoDB;

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
-- 6) VEHICLE
CREATE TABLE VEHICLE (
    VehicleID    INT           NOT NULL AUTO_INCREMENT,
    ShipperID    INT           NOT NULL,
    Brand        VARCHAR(50)   NOT NULL,
    Model        VARCHAR(50)   NOT NULL,
    LicensePlate VARCHAR(15)   NOT NULL,
    Color        VARCHAR(30)   NOT NULL,
    MaximumLoad  DECIMAL(8,2)  NOT NULL,
    VehicleType  VARCHAR(20)   NOT NULL,
    CONSTRAINT pk_vehicle PRIMARY KEY (VehicleID),
    CONSTRAINT uq_vehicle_shipper UNIQUE (ShipperID),
    CONSTRAINT uq_vehicle_plate UNIQUE (LicensePlate),
    CONSTRAINT fk_vehicle_shipper FOREIGN KEY (ShipperID)
        REFERENCES SHIPPER (UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_vehicle_load CHECK (MaximumLoad > 0),
    CONSTRAINT chk_vehicle_plate
        CHECK (LicensePlate REGEXP '^[0-9]{2}-?[A-Z][A-Z0-9]?[ -]?[0-9]{3}\\.?[0-9]{2}$'),
    CONSTRAINT chk_vehicle_type
        CHECK (VehicleType IN ('motorbike', 'car', 'van', 'truck')),
    INDEX idx_vehicle_type (VehicleType)
) ENGINE = InnoDB;

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

-- ============================================================================
-- GROUP C TABLES: PAYMENTS, PROMOTIONS AND REVIEWS — Lê Tuấn
-- Tables: PAYMENT, PROMOTION, APPLIED_TO, POINT_TRANSACTION, FEEDBACK, SHIPPER_EARNING
-- ============================================================================

-- 11) PAYMENT
CREATE TABLE PAYMENT (
    PaymentID       INT           NOT NULL AUTO_INCREMENT,
    OrderID         INT           NOT NULL,
    PaymentMethod   VARCHAR(20)   NOT NULL,
    PaidBy          VARCHAR(20)   NOT NULL,
    Amount          DECIMAL(15,2) NOT NULL,
    PaymentStatus   VARCHAR(20)   NOT NULL DEFAULT 'completed',
    TransactionCode VARCHAR(50)   NOT NULL,
    PaymentDate     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_payment PRIMARY KEY (PaymentID),
    CONSTRAINT uq_payment_order UNIQUE (OrderID),
    CONSTRAINT uq_payment_trans UNIQUE (TransactionCode),
    CONSTRAINT fk_payment_order FOREIGN KEY (OrderID)
        REFERENCES DELIVERY_ORDER (OrderID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_payment_method
        CHECK (PaymentMethod IN ('cash', 'card', 'e_wallet', 'bank_transfer')),
    CONSTRAINT chk_payment_paidby
        CHECK (PaidBy IN ('sender', 'recipient')),
    CONSTRAINT chk_payment_amount
        CHECK (Amount > 0),
    CONSTRAINT chk_payment_status
        CHECK (PaymentStatus IN ('completed', 'pending', 'refunded')),
    INDEX idx_payment_date (PaymentDate)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- 12) PROMOTION
CREATE TABLE PROMOTION (
    PromotionID       INT           NOT NULL AUTO_INCREMENT,
    PromotionCode     VARCHAR(50)   NOT NULL,
    PromotionName     VARCHAR(100)  NOT NULL,
    Description       VARCHAR(500)  NULL,
    DiscountType      VARCHAR(20)   NOT NULL,
    DiscountValue     DECIMAL(10,2) NOT NULL,
    MaximumDiscount   DECIMAL(15,2) NULL,
    MinimumOrderValue DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    StartDate         DATETIME      NOT NULL,
    EndDate           DATETIME      NOT NULL,
    UsageLimit        INT           NOT NULL,
    PromotionStatus   VARCHAR(20)   NOT NULL DEFAULT 'active',
    CONSTRAINT pk_promotion PRIMARY KEY (PromotionID),
    CONSTRAINT uq_promotion_code UNIQUE (PromotionCode),
    CONSTRAINT chk_promo_type
        CHECK (DiscountType IN ('percentage', 'fixed')),
    CONSTRAINT chk_promo_value
        CHECK (DiscountValue > 0),
    CONSTRAINT chk_promo_pct
        CHECK (DiscountType <> 'percentage' OR DiscountValue <= 100),
    CONSTRAINT chk_promo_max_discount
        CHECK (MaximumDiscount IS NULL OR MaximumDiscount >= 0),
    CONSTRAINT chk_promo_min_order
        CHECK (MinimumOrderValue >= 0),
    CONSTRAINT chk_promo_dates
        CHECK (EndDate >= StartDate),
    CONSTRAINT chk_promo_limit
        CHECK (UsageLimit > 0),
    CONSTRAINT chk_promo_status
        CHECK (PromotionStatus IN ('active', 'inactive', 'expired')),
    INDEX idx_promo_status_dates (PromotionStatus, StartDate, EndDate)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- 13) APPLIED_TO (associative table for DELIVERY_ORDER <-> PROMOTION)
CREATE TABLE APPLIED_TO (
    OrderID        INT           NOT NULL,
    PromotionID    INT           NOT NULL,
    DiscountAmount DECIMAL(15,2) NOT NULL,
    AppliedDate    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_applied_to PRIMARY KEY (OrderID, PromotionID),
    CONSTRAINT fk_applied_order FOREIGN KEY (OrderID)
        REFERENCES DELIVERY_ORDER (OrderID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_applied_promo FOREIGN KEY (PromotionID)
        REFERENCES PROMOTION (PromotionID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_applied_discount
        CHECK (DiscountAmount >= 0),
    INDEX idx_applied_promo (PromotionID)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- 14) POINT_TRANSACTION
CREATE TABLE POINT_TRANSACTION (
    PointTransactionID INT          NOT NULL AUTO_INCREMENT,
    CustomerID         INT          NOT NULL,
    OrderID            INT          NULL,
    PointAmount        INT          NOT NULL,
    TransactionType    VARCHAR(20)  NOT NULL,
    TransactionDate    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Description        VARCHAR(500) NULL,
    CONSTRAINT pk_point_transaction PRIMARY KEY (PointTransactionID),
    CONSTRAINT uq_point_order UNIQUE (OrderID),
    CONSTRAINT fk_point_customer FOREIGN KEY (CustomerID)
        REFERENCES CUSTOMER (UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_point_order FOREIGN KEY (OrderID)
        REFERENCES DELIVERY_ORDER (OrderID) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_point_type
        CHECK (TransactionType IN ('earn', 'redeem', 'adjustment')),
    CONSTRAINT chk_point_amount
        CHECK ((TransactionType = 'earn' AND PointAmount > 0)
            OR (TransactionType = 'redeem' AND PointAmount < 0)
            OR (TransactionType = 'adjustment')),
    INDEX idx_point_customer_date (CustomerID, TransactionDate)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- 15) FEEDBACK
CREATE TABLE FEEDBACK (
    FeedbackID   INT           NOT NULL AUTO_INCREMENT,
    OrderID      INT           NOT NULL,
    CustomerID   INT           NOT NULL,
    ShipperID    INT           NOT NULL,
    Rating       TINYINT       NOT NULL,
    Comment      VARCHAR(1000) NULL,
    CreatedDate  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FeedbackType VARCHAR(20)   NOT NULL,
    CONSTRAINT pk_feedback PRIMARY KEY (FeedbackID),
    CONSTRAINT uq_feedback_party_order UNIQUE (OrderID, FeedbackType),
    CONSTRAINT fk_feedback_order FOREIGN KEY (OrderID)
        REFERENCES DELIVERY_ORDER (OrderID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_feedback_customer FOREIGN KEY (CustomerID)
        REFERENCES CUSTOMER (UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_feedback_shipper FOREIGN KEY (ShipperID)
        REFERENCES SHIPPER (UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_feedback_rating
        CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT chk_feedback_type
        CHECK (FeedbackType IN ('customer', 'shipper')),
    INDEX idx_feedback_shipper (ShipperID, FeedbackType, Rating)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- 16) SHIPPER_EARNING
CREATE TABLE SHIPPER_EARNING (
    EarningID          INT           NOT NULL AUTO_INCREMENT,
    ShipperID          INT           NOT NULL,
    OrderID            INT           NOT NULL,
    DeliveryFee        DECIMAL(15,2) NOT NULL,
    PlatformCommission DECIMAL(15,2) NOT NULL,
    NetEarning         DECIMAL(15,2) GENERATED ALWAYS AS (DeliveryFee - PlatformCommission) STORED,
    EarningDate        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PayoutStatus       VARCHAR(20)   NOT NULL DEFAULT 'pending',
    PayoutDate         DATETIME      NULL,
    CONSTRAINT pk_shipper_earning PRIMARY KEY (EarningID),
    CONSTRAINT uq_earning_order UNIQUE (OrderID),
    CONSTRAINT fk_earning_shipper FOREIGN KEY (ShipperID)
        REFERENCES SHIPPER (UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_earning_order FOREIGN KEY (OrderID)
        REFERENCES DELIVERY_ORDER (OrderID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_earning_fee
        CHECK (DeliveryFee >= 0),
    CONSTRAINT chk_earning_commission
        CHECK (PlatformCommission >= 0 AND PlatformCommission <= DeliveryFee),
    CONSTRAINT chk_earning_payout_status
        CHECK (PayoutStatus IN ('pending', 'processing', 'paid', 'cancelled')),
    CONSTRAINT chk_earning_payout_date
        CHECK ((PayoutStatus = 'paid' AND PayoutDate IS NOT NULL AND PayoutDate >= EarningDate)
            OR (PayoutStatus <> 'paid' AND PayoutDate IS NULL)),
    INDEX idx_earning_shipper_date (ShipperID, EarningDate)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

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
