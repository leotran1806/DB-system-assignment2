USE parcel_delivery;

-- Run after 01, 02, 03 in a dedicated demo connection with no pending work.
-- The helper catches expected errors and rolls back every test's data changes.
DELIMITER $$
CREATE PROCEDURE duy_test_trigger1()
BEGIN
    DECLARE caught INT DEFAULT 0;
    DECLARE msg TEXT DEFAULT '';
    DECLARE failures INT DEFAULT 0;
    DECLARE actual_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*) INTO actual_count FROM DELIVERY_ORDER
    WHERE OrderID = 92004 AND OrderStatus = 'completed';
    IF actual_count <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Load the unmodified demo data before tests.';
    END IF;

    START TRANSACTION;
    UPDATE DELIVERY_ORDER SET Note = 'Allowed edit' WHERE OrderID = 92004;
    SELECT COUNT(*) INTO actual_count FROM DELIVERY_ORDER
    WHERE OrderID = 92004 AND Note = 'Allowed edit' AND OrderStatus = 'completed';
    SELECT 'T1: edit completed order note' AS Test, IF(actual_count=1,'PASS','FAIL') AS Result;
    SET failures = failures + IF(actual_count=1,0,1);
    ROLLBACK;

    START TRANSACTION;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 caught = MYSQL_ERRNO, msg = MESSAGE_TEXT;
        END;
        UPDATE DELIVERY_ORDER SET OrderStatus='delivering', CompleteDate=NULL WHERE OrderID=92004;
    END;
    SELECT 'T2: completed to delivering' AS Test,
        IF(caught=1644 AND msg='Completed order cannot change to another status.','PASS','FAIL') AS Result, msg AS Message;
    SET failures=failures+IF(caught=1644 AND msg='Completed order cannot change to another status.',0,1);
    ROLLBACK;

    SET caught=0; SET msg='';
    START TRANSACTION;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 caught = MYSQL_ERRNO, msg = MESSAGE_TEXT;
        END;
        UPDATE DELIVERY_ORDER SET OrderStatus='placed', CompleteDate=NULL WHERE OrderID=92004;
    END;
    SELECT 'T3: completed to placed' AS Test, IF(caught=1644,'PASS','FAIL') AS Result;
    SET failures=failures+IF(caught=1644,0,1);
    ROLLBACK;

    SET caught=0;
    START TRANSACTION;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 caught = MYSQL_ERRNO;
        END;
        UPDATE DELIVERY_ORDER SET OrderStatus='cancelled', CompleteDate=NULL,
            CancellationReason='Test cancellation' WHERE OrderID=92004;
    END;
    SELECT 'T4: completed to cancelled' AS Test, IF(caught=1644,'PASS','FAIL') AS Result;
    SET failures=failures+IF(caught=1644,0,1);
    ROLLBACK;

    SET caught=0;
    START TRANSACTION;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 caught = MYSQL_ERRNO;
        END;
        UPDATE DELIVERY_ORDER SET OrderStatus='placed', CompleteDate=NULL, Note='Batch edit'
        WHERE OrderID IN (92003,92004) ORDER BY OrderID;
    END;
    SELECT COUNT(*) INTO actual_count FROM DELIVERY_ORDER
    WHERE (OrderID=92003 AND OrderStatus='delivering' AND Note='Demo order 3')
       OR (OrderID=92004 AND OrderStatus='completed' AND Note='Demo order 4');
    SELECT 'T5: failed batch leaves both rows unchanged' AS Test,
        IF(caught=1644 AND actual_count=2,'PASS','FAIL') AS Result;
    SET failures=failures+IF(caught=1644 AND actual_count=2,0,1);
    ROLLBACK;

    SELECT failures AS FailedTests, IF(failures=0,'ALL PASS','TESTS FAILED') AS Summary;
    IF failures>0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Trigger tests failed; inspect result sets.';
    END IF;
END$$
DELIMITER ;
CALL duy_test_trigger1();
DROP PROCEDURE duy_test_trigger1;
