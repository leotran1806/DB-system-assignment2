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
-- TODO procedure 1: sp_InsertShipper
-- Parameters: p_UserID, p_NationalIdentificationNumber, p_AvailabilityStatus,
--             p_JoinDate, p_ManagedByAdminID.
-- Steps: validate all input values; check parent/manager rows; check duplicates;
-- insert into SHIPPER; return the created UserID or a success result set.
-- Use INSERT only here for the chosen target table (or document any required
-- parent/child writes if the team changes the selected logical entity scope).
--
-- TODO procedure 2: sp_UpdateShipper
-- Parameters: p_UserID plus the same mutable SHIPPER attributes.
-- Steps: confirm row exists; validate each field; check NIN uniqueness excluding
-- p_UserID; check references; perform UPDATE; return clear success status.
--
-- TODO procedure 3: sp_DeleteShipper
-- Parameter: p_UserID.
-- Steps: confirm row exists; check the deletion policy above; if deletion is
-- allowed, perform the agreed deletion safely; otherwise SIGNAL a meaningful
-- message or deactivate according to the documented policy. Never silently
-- delete rows that are required for historical delivery records.
--
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
CREATE PROCEDURE sp_RevenueByShipper(IN fromDate DATE, IN toDate DATE, IN minOrders INT)
BEGIN
    IF fromDate is NULL or toDate is NULL THEN:
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This field cannot be NULL';
    IF fromDate > toDate THEN:
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "From date cannot be after to date"
    IF minOrders is NULL OR minOrders < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Minimum orders not be NULL or negative'
    SELECT u.id
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
