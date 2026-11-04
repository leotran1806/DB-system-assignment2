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

-- ---------------------------- INSERT ----------------------------------------
-- I1  ERROR  user does not exist                                -> User does not exist.
CALL sp_InsertShipper(999, '079098111333', 'offline', 4);
-- I2  ERROR  user ID is NULL                                    -> User ID must be provided.
CALL sp_InsertShipper(NULL, '079098111333', 'offline', 4);
-- I3  ERROR  user 28 is suspended                               -> The user account is not active...
CALL sp_InsertShipper(28, '079098111333', 'offline', 4);
-- I4  ERROR  user 27 is 16 years old                            -> The user must be at least 18 years old...
CALL sp_InsertShipper(27, '079098111333', 'offline', 4);
-- I5  ERROR  user 16 is already a shipper                       -> This user is already a shipper.
CALL sp_InsertShipper(16, '079098111333', 'offline', 4);
-- I6  ERROR  user 6 is a customer                               -> This user is a customer...
CALL sp_InsertShipper(6, '079098111333', 'offline', 4);
-- I7  ERROR  user 1 is an admin                                 -> This user is an admin...
CALL sp_InsertShipper(1, '079098111333', 'offline', 4);
-- I8  ERROR  national ID too short                              -> ...exactly 12 digits and start with 0.
CALL sp_InsertShipper(26, '123', 'offline', 4);
-- I9  ERROR  national ID does not start with 0
CALL sp_InsertShipper(26, '179098111333', 'offline', 4);
-- I10 ERROR  national ID has 13 digits
CALL sp_InsertShipper(26, '0790981113334', 'offline', 4);
-- I11 ERROR  national ID already used by shipper 16             -> ...already belongs to another shipper.
CALL sp_InsertShipper(26, '079095123401', 'offline', 4);
-- I12 ERROR  invalid availability                               -> Availability status must be available, busy or offline.
CALL sp_InsertShipper(26, '079098111333', 'sleeping', 4);
-- I13 ERROR  admin missing (NULL)                               -> Managing admin must be provided.
CALL sp_InsertShipper(26, '079098111333', 'offline', NULL);
-- I14 ERROR  admin does not exist                               -> Managing admin does not exist.
CALL sp_InsertShipper(26, '079098111333', 'offline', 99);
-- I15 ERROR  admin 5 is suspended                               -> Managing admin account is not active.
CALL sp_InsertShipper(26, '079098111333', 'offline', 5);
-- I16 OK     user 26 (adult, active, no role): run this one LAST, after all the error cases -> inserted
CALL sp_InsertShipper(26, '079098111222', 'offline', 4);
-- Check I16:
SELECT * FROM SHIPPER WHERE UserID = 26;
 
-- ---------------------------- UPDATE ----------------------------------------
-- U1  OK     shipper 22: change availability to offline         -> updated
CALL sp_UpdateShipper(22, '031200789007', 'offline', 4);
-- U2  OK     same values again                                  -> unchanged
CALL sp_UpdateShipper(22, '031200789007', 'offline', 4);
-- U3  OK     change the managing admin to admin 1               -> updated
CALL sp_UpdateShipper(22, '031200789007', 'available', 1);
-- U4  ERROR  shipper does not exist                             -> Shipper does not exist.
CALL sp_UpdateShipper(999, '031200789007', 'offline', 4);
-- U5  ERROR  bad national ID                                    -> ...exactly 12 digits and start with 0.
CALL sp_UpdateShipper(22, '12345', 'offline', 4);
-- U6  ERROR  national ID of shipper 16                          -> ...already belongs to another shipper.
CALL sp_UpdateShipper(22, '079095123401', 'offline', 4);
-- U7  ERROR  invalid availability                               -> Availability status must be available, busy or offline.
CALL sp_UpdateShipper(22, '031200789007', 'sleeping', 4);
-- U8  ERROR  shipper 24 is suspended and cannot be available    -> A suspended or closed shipper can only be offline.
CALL sp_UpdateShipper(24, '087093901209', 'available', 2);
-- U9  ERROR  shipper 18 has an accepted assignment              -> Cannot set the shipper offline while...
CALL sp_UpdateShipper(18, '048197345603', 'offline', 2);
-- U10 ERROR  admin missing (NULL)                               -> Managing admin must be provided.
CALL sp_UpdateShipper(22, '031200789007', 'available', NULL);
-- U11 ERROR  admin does not exist                               -> Managing admin does not exist.
CALL sp_UpdateShipper(22, '031200789007', 'available', 99);
-- U12 ERROR  admin 5 is suspended                               -> Managing admin account is not active.
CALL sp_UpdateShipper(22, '031200789007', 'available', 5);
-- Put shipper 22 back to its sample values:
CALL sp_UpdateShipper(22, '031200789007', 'available', 4);
 
-- ---------------------------- DELETE ----------------------------------------
-- D1  ERROR  shipper 18 has an assignment                       -> Cannot delete: ...delivery assignments...
CALL sp_DeleteShipper(18);
-- D2  ERROR  shipper 17 has an earning                          -> Cannot delete: ...earning records...
CALL sp_DeleteShipper(17);
-- D3  ERROR  shipper 19 has feedback                            -> Cannot delete: ...feedback records...
CALL sp_DeleteShipper(19);
-- D4  ERROR  shipper 20 is in the status history                -> Cannot delete: ...order status history...
CALL sp_DeleteShipper(20);
-- D5  ERROR  shipper does not exist                             -> Shipper does not exist.
CALL sp_DeleteShipper(999);
-- D6  ERROR  NULL                                               -> Shipper does not exist.
CALL sp_DeleteShipper(NULL);
-- D7  ERROR  user 6 is a customer, not a shipper                -> Shipper does not exist.
CALL sp_DeleteShipper(6);
-- Run D8 and D9 last: they remove data. Reload the sample data to repeat the test.
-- D8  OK     shipper 26 (inserted in I1, no history)            -> deleted
CALL sp_DeleteShipper(26);
-- D9  OK     shipper 22 has a vehicle and a licence, no history -> deleted (SHIPPER_LICENSE, VEHICLE, SHIPPER)
CALL sp_DeleteShipper(22);
-- D10 OK     shipper 25 has no vehicle                          -> deleted
CALL sp_DeleteShipper(25);
SELECT 'user 22 still exists' AS Check1, COUNT(*) AS Total FROM `USER` WHERE UserID = 22;
SELECT 'vehicle of shipper 22 removed' AS Check2, COUNT(*) AS Total FROM VEHICLE WHERE ShipperID = 22;
 
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
