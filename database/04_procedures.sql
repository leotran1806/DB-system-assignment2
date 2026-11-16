-- ============================================================================
-- 04_procedures.sql | A2 - Sections 2.1 (1 point) and 2.3 (1 point)
-- STARTER FILE: implement the five procedures below.
-- CRUD target selected for 2.1: SHIPPER.
-- ============================================================================
USE parcel_delivery;

-- ---------------------------------------------------------------------------
-- 2.1: CRUD procedures for SHIPPER
-- For the report, explain the deletion policy and why it is needed.
-- Suggested policy:
--   * Physical deletion is allowed only when the shipper has no delivery
--     assignments/history, no earnings, no feedback and no dependent records
--     that must be preserved.
--   * If the shipper has historical business records, preserve those records;
--     either reject deletion with a specific message OR mark account closed and
--     availability offline. State which policy your team chose.
--   * Purpose: remove erroneous/test profiles while preserving delivery/audit
--     history and referential integrity for real shippers.
--
-- Validation checklist for INSERT and UPDATE:
--   [ ] target shipper exists for UPDATE / does not already exist for INSERT
--   [ ] referenced USER and optional ADMIN exist
--   [ ] NIN is 9 or 12 digits and unique (exclude current UserID on UPDATE)
--   [ ] AvailabilityStatus is available/busy/offline
--   [ ] JoinDate has an accepted value
--   [ ] account state is compatible with availability if you validate USER too
--   [ ] clear SIGNAL SQLSTATE '45000' message for every specific failure
--   [ ] transaction + rollback if the routine changes dependent tables
--
-- ---------------------------------------------------------------------------
-- sp_InsertShipper: create USER + SHIPPER + VEHICLE + SHIPPER_LICENSE in one transaction
-- ---------------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_InsertShipper$$
CREATE PROCEDURE sp_InsertShipper(
    IN p_Email VARCHAR(100),
    IN p_PhoneNumber VARCHAR(10),
    IN p_Password VARCHAR(255),
    IN p_DateOfBirth DATE,
    IN p_Gender VARCHAR(10),
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_NationalIdentificationNumber VARCHAR(12),
    IN p_ManagedByAdminID INT,
    IN p_LicenseNumber VARCHAR(12),
    IN p_LicenseType VARCHAR(5),
    IN p_LicenseIssueDate DATE,
    IN p_LicenseExpiryDate DATE,
    IN p_Brand VARCHAR(50),
    IN p_Model VARCHAR(50),
    IN p_LicensePlate VARCHAR(15),
    IN p_Color VARCHAR(30),
    IN p_MaximumLoad DECIMAL(8,2),
    IN p_VehicleType VARCHAR(20)
)
BEGIN
    DECLARE v_NewUserID INT;

    -- Roll back everything if any unexpected SQL error happens
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- ===== Validation: user information =====
    IF p_FirstName IS NULL OR TRIM(p_FirstName) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'First name must not be empty.';
    END IF;
    IF p_LastName IS NULL OR TRIM(p_LastName) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Last name must not be empty.';
    END IF;
    IF p_DateOfBirth IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Date of birth must be provided.';
    END IF;
    IF TIMESTAMPDIFF(YEAR, p_DateOfBirth, CURDATE()) < 18 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The shipper must be at least 18 years old.';
    END IF;
    IF p_Gender IS NULL OR p_Gender NOT IN ('male', 'female') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gender must be male or female.';
    END IF;
    IF p_Email IS NULL OR p_Email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email format is invalid.';
    END IF;
    IF EXISTS (SELECT 1 FROM `USER` WHERE Email = p_Email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This email is already used by another account.';
    END IF;
    IF p_PhoneNumber IS NULL OR p_PhoneNumber NOT REGEXP '^0[0-9]{9}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phone number must be exactly 10 digits and start with 0.';
    END IF;
    IF EXISTS (SELECT 1 FROM `USER` WHERE PhoneNumber = p_PhoneNumber) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This phone number is already used by another account.';
    END IF;
    IF p_Password IS NULL OR CHAR_LENGTH(p_Password) < 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password must have at least 8 characters.';
    END IF;

    -- ===== Validation: shipper information =====
    IF p_NationalIdentificationNumber IS NULL
       OR p_NationalIdentificationNumber NOT REGEXP '^0[0-9]{11}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'National ID must be exactly 12 digits and start with 0.';
    END IF;
    IF EXISTS (SELECT 1 FROM SHIPPER WHERE NationalIdentificationNumber = p_NationalIdentificationNumber) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This national ID already belongs to another shipper.';
    END IF;
    IF p_ManagedByAdminID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Managing admin must be provided.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ADMIN WHERE UserID = p_ManagedByAdminID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Managing admin does not exist.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM `USER` WHERE UserID = p_ManagedByAdminID AND AccountStatus = 'active') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Managing admin account is not active.';
    END IF;

    -- ===== Validation: driving licence =====
    IF p_LicenseNumber IS NULL OR p_LicenseNumber NOT REGEXP '^[0-9]{9,12}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Licence number must be 9 to 12 digits.';
    END IF;
    IF EXISTS (SELECT 1 FROM SHIPPER_LICENSE WHERE LicenseNumber = p_LicenseNumber) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This licence number is already registered.';
    END IF;
    IF p_LicenseType IS NULL OR p_LicenseType NOT IN ('A1', 'A2', 'B1', 'B2', 'C') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Licence type must be A1, A2, B1, B2 or C.';
    END IF;
    IF p_LicenseIssueDate IS NULL OR p_LicenseExpiryDate IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Licence issue date and expiry date must be provided.';
    END IF;
    IF p_LicenseExpiryDate <= p_LicenseIssueDate THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Licence expiry date must be after the issue date.';
    END IF;
    IF p_LicenseExpiryDate < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The driving licence has expired.';
    END IF;

    -- ===== Validation: vehicle =====
    IF p_VehicleType IS NULL OR p_VehicleType NOT IN ('motorbike', 'car', 'van', 'truck') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehicle type must be motorbike, car, van or truck.';
    END IF;
    IF p_LicensePlate IS NULL
       OR p_LicensePlate NOT REGEXP '^[0-9]{2}-?[A-Z][A-Z0-9]?[ -]?[0-9]{3}\\.?[0-9]{2}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Licence plate format is invalid.';
    END IF;
    IF EXISTS (SELECT 1 FROM VEHICLE WHERE LicensePlate = p_LicensePlate) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This licence plate is already registered.';
    END IF;
    IF p_MaximumLoad IS NULL OR p_MaximumLoad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maximum load must be greater than 0.';
    END IF;
    IF p_Brand IS NULL OR TRIM(p_Brand) = '' OR p_Model IS NULL OR TRIM(p_Model) = ''
       OR p_Color IS NULL OR TRIM(p_Color) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehicle brand, model and color must not be empty.';
    END IF;

    -- ===== Validation: licence type must allow this vehicle =====
    IF p_VehicleType = 'motorbike' AND p_LicenseType NOT IN ('A1', 'A2') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A motorbike requires an A1 or A2 licence.';
    END IF;
    IF p_VehicleType IN ('car', 'van') AND p_LicenseType NOT IN ('B1', 'B2', 'C') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A car or van requires a B1, B2 or C licence.';
    END IF;
    IF p_VehicleType = 'truck' AND p_LicenseType NOT IN ('B2', 'C') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A truck requires a B2 or C licence.';
    END IF;

    -- ===== All checks passed: insert into 4 tables =====
    START TRANSACTION;

    INSERT INTO `USER` (Email, PhoneNumber, PasswordHash, AccountStatus, CreatedDate,
                        DateOfBirth, Gender, FirstName, LastName)
    VALUES (p_Email, p_PhoneNumber, SHA2(p_Password, 256), 'active', CURDATE(),
            p_DateOfBirth, p_Gender, TRIM(p_FirstName), TRIM(p_LastName));

    SET v_NewUserID = LAST_INSERT_ID();

    INSERT INTO SHIPPER (UserID, NationalIdentificationNumber, AvailabilityStatus,
                         JoinDate, ManagedByAdminID)
    VALUES (v_NewUserID, p_NationalIdentificationNumber, 'offline', CURDATE(), p_ManagedByAdminID);

    INSERT INTO SHIPPER_LICENSE (ShipperID, LicenseNumber, LicenseType, IssueDate, ExpiryDate)
    VALUES (v_NewUserID, p_LicenseNumber, p_LicenseType, p_LicenseIssueDate, p_LicenseExpiryDate);

    INSERT INTO VEHICLE (ShipperID, Brand, Model, LicensePlate, Color, MaximumLoad, VehicleType)
    VALUES (v_NewUserID, TRIM(p_Brand), TRIM(p_Model), p_LicensePlate, TRIM(p_Color),
            p_MaximumLoad, p_VehicleType);

    COMMIT;

    SELECT v_NewUserID AS NewShipperID, 'Shipper created successfully.' AS Message;
END$$

DELIMITER ;

-- Template signatures (uncomment and complete one at a time):
-- DELIMITER $$
-- CREATE PROCEDURE sp_InsertShipper(
--     IN p_UserID INT,
--     IN p_NationalIdentificationNumber VARCHAR(12),
--     IN p_AvailabilityStatus VARCHAR(20),
--     IN p_JoinDate DATE,
--     IN p_ManagedByAdminID INT
-- )
-- BEGIN
--     -- TODO: validation SELECT COUNT(*) INTO variables; SIGNAL on each error.
--     -- TODO: INSERT into SHIPPER after all validations pass.
-- END$$
--
-- CREATE PROCEDURE sp_UpdateShipper(
--     IN p_UserID INT,
--     IN p_NationalIdentificationNumber VARCHAR(12),
--     IN p_AvailabilityStatus VARCHAR(20),
--     IN p_JoinDate DATE,
--     IN p_ManagedByAdminID INT
-- )
-- BEGIN
--     -- TODO: existence check, field validation, unique check excluding p_UserID.
--     -- TODO: UPDATE SHIPPER and return a success result.
-- END$$
--
-- CREATE PROCEDURE sp_DeleteShipper(IN p_UserID INT)
-- BEGIN
--     -- TODO: check dependencies/history; implement and document delete policy.
-- END$$

-- ---------------------------------------------------------------------------
-- 2.3: TWO QUERY-ONLY stored procedures
-- Both procedures must contain SELECT statements only (no INSERT/UPDATE/DELETE).
-- Their input parameters must be used in WHERE and/or HAVING filters.
-- ---------------------------------------------------------------------------

-- TODO procedure 4: sp_ListShippers (query 1)
-- Required: JOIN at least two tables (recommended USER + SHIPPER + VEHICLE),
-- WHERE filters and ORDER BY. Input parameters should correspond to filters:
-- p_Search, p_AvailabilityStatus, p_AccountStatus, p_VehicleType, p_SortBy.
-- It must retrieve SHIPPER data because this is the CRUD table in 2.1.
-- Suggested output aliases expected by the current template:
-- UserID, FullName, Email, PhoneNumber, NationalIdentificationNumber,
-- AvailabilityStatus, AccountStatus, VehicleType, LicensePlate, JoinDate,
-- AverageRating, ManagedByAdminID.
-- Validate/whitelist p_SortBy. Use CASE expressions in ORDER BY rather than
-- concatenating arbitrary user-provided SQL text.

-- TODO procedure 5: sp_RevenueByShipper (query 2)
-- Required: JOIN at least two tables, WHERE, aggregate functions (SUM/COUNT),
-- GROUP BY, HAVING, ORDER BY. Input parameters: p_FromDate, p_ToDate,
-- p_MinOrders (or other values actually used by WHERE/HAVING).
-- Recommended joins: SHIPPER + USER + SHIPPER_EARNING.
-- Output aliases expected by reports/index.html:
-- ShipperID, ShipperName, TotalOrders, TotalDeliveryFee,
-- TotalCommission, TotalNetEarning.
-- It must be a read-only procedure; use its output in the Reports screen.

-- Template query-only procedure structure:
-- CREATE PROCEDURE sp_ListShippers(IN p_Search VARCHAR(100), ...)
-- BEGIN
--     SELECT ...
--       FROM SHIPPER s
--       JOIN `USER` u ON ...
--       LEFT JOIN VEHICLE v ON ...
--      WHERE (p_Search IS NULL OR ...)
--        AND (p_AvailabilityStatus IS NULL OR ...)
--      ORDER BY ...;
-- END$$
--
DROP PROCEDURE IF EXISTS sp_RevenueByShipper$$
CREATE PROCEDURE sp_RevenueByShipper(IN fromDate DATE, IN toDate DATE, IN minOrders INT)
BEGIN
    IF fromDate is NULL or toDate is NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This field cannot be empty';
    END IF;
    IF fromDate > toDate THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'From date cannot be after to date';
    END IF;
    IF minOrders is NULL OR minOrders < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Minimum orders not be NULL or negative';
    END IF;
    SELECT u.UserID AS ShipperID,
           CONCAT(u.LastName, ' ', u.FirstName) AS ShipperName,
           COUNT(se.EarningID) AS TotalOrders,
           SUM(se.DeliveryFee) AS TotalDeliveryFee,
           SUM(se.PlatformCommission) AS TotalCommission,
           SUM(se.DeliveryFee - se.PlatformCommission) AS TotalNetEarning
        FROM `USER` u 
        JOIN SHIPPER s ON u.UserID = s.UserID
        JOIN SHIPPER_EARNING se ON u.UserID = se.ShipperID
        WHERE se.EarningDate >= fromDate AND se.EarningDate < DATE_ADD(toDate, INTERVAL 1 DAY)
        GROUP BY u.UserID, u.LastName, u.FirstName
        HAVING COUNT(se.EarningID) >= minOrders
        ORDER BY ShipperID ASC;
END$$
DELIMETER ;
-- CREATE PROCEDURE sp_RevenueByShipper(IN p_FromDate DATE, ...)
-- BEGIN
--     SELECT ..., COUNT(...), SUM(...)
--       FROM SHIPPER_EARNING e
--       JOIN SHIPPER s ON ...
--       JOIN `USER` u ON ...
--      WHERE e.EarningDate >= p_FromDate
--        AND e.EarningDate < DATE_ADD(p_ToDate, INTERVAL 1 DAY)
--      GROUP BY ...
--     HAVING COUNT(...) >= p_MinOrders
--      ORDER BY ...;
-- END$$
-- DELIMITER ;
