-- ============================================================================
-- test_trigger2.sql | A2 - Section 2.2.2 Derived Attribute Trigger Test Suite
-- Author: Lê Tuấn
-- Tests derivation of SHIPPER.AverageRating from FEEDBACK (INSERT, UPDATE, DELETE)
-- ============================================================================
USE parcel_delivery;

DELIMITER $$

DROP PROCEDURE IF EXISTS tuan_test_trigger2$$
CREATE PROCEDURE tuan_test_trigger2()
BEGIN
    DECLARE failures INT DEFAULT 0;
    DECLARE actual_rating DECIMAL(3,2) DEFAULT 0.00;
    DECLARE actual_count INT DEFAULT 0;
    DECLARE start_rating_22 DECIMAL(3,2) DEFAULT 0.00;
    DECLARE start_rating_23 DECIMAL(3,2) DEFAULT 0.00;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Ensure base sample data is present
    SELECT COUNT(*) INTO actual_count FROM SHIPPER WHERE UserID IN (22, 23);
    IF actual_count < 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Please load 01_create_tables and 02_sample_data before running tests.';
    END IF;

    -- Record starting AverageRating for Shipper 23 (fresh shipper, expected 0.00)
    SELECT AverageRating INTO start_rating_23 FROM SHIPPER WHERE UserID = 23;

    -- ------------------------------------------------------------------------
    -- T1: Verify starting state of Shipper 23 with 0 customer feedback (AverageRating = 0.00)
    -- ------------------------------------------------------------------------
    SELECT 'T1: baseline AverageRating for shipper 23 with no customer feedback' AS Test,
        IF(start_rating_23 = 0.00, 'PASS', 'FAIL') AS Result,
        start_rating_23 AS CurrentRating;
    SET failures = failures + IF(start_rating_23 = 0.00, 0, 1);

    -- ------------------------------------------------------------------------
    -- T2: INSERT 1st Customer Feedback (Rating 4) -> AverageRating becomes 4.00
    -- ------------------------------------------------------------------------
    START TRANSACTION;
    INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType)
    VALUES (95001, 92004, 91004, 23, 4, 'Test customer review 4 stars', NOW(), 'customer');

    SELECT AverageRating INTO actual_rating FROM SHIPPER WHERE UserID = 23;
    SELECT 'T2: INSERT customer feedback (Rating=4) -> AverageRating=4.00' AS Test,
        IF(actual_rating = 4.00, 'PASS', 'FAIL') AS Result,
        actual_rating AS CurrentRating;
    SET failures = failures + IF(actual_rating = 4.00, 0, 1);
    ROLLBACK;

    -- ------------------------------------------------------------------------
    -- T3: INSERT multiple Customer Feedbacks (Rating 4 and Rating 5) -> AverageRating = 4.50
    -- ------------------------------------------------------------------------
    START TRANSACTION;
    INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType)
    VALUES (95001, 92004, 91004, 23, 4, 'Test review 1', NOW(), 'customer');
    INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType)
    VALUES (95002, 92006, 6, 23, 5, 'Test review 2', NOW(), 'customer');

    SELECT AverageRating INTO actual_rating FROM SHIPPER WHERE UserID = 23;
    SELECT 'T3: INSERT two customer feedbacks (4 and 5) -> AverageRating=4.50' AS Test,
        IF(actual_rating = 4.50, 'PASS', 'FAIL') AS Result,
        actual_rating AS CurrentRating;
    SET failures = failures + IF(actual_rating = 4.50, 0, 1);
    ROLLBACK;

    -- ------------------------------------------------------------------------
    -- T4: INSERT Shipper Feedback (Rating 1, FeedbackType='shipper') -> must NOT alter AverageRating
    -- ------------------------------------------------------------------------
    START TRANSACTION;
    INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType)
    VALUES (95001, 92004, 91004, 23, 4, 'Customer review', NOW(), 'customer');
    -- Shipper rates customer (1 star) on order 92004
    INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType)
    VALUES (95002, 92004, 91004, 23, 1, 'Shipper review about customer', NOW(), 'shipper');

    SELECT AverageRating INTO actual_rating FROM SHIPPER WHERE UserID = 23;
    SELECT 'T4: INSERT shipper feedback (Rating=1) -> AverageRating unchanged at 4.00' AS Test,
        IF(actual_rating = 4.00, 'PASS', 'FAIL') AS Result,
        actual_rating AS CurrentRating;
    SET failures = failures + IF(actual_rating = 4.00, 0, 1);
    ROLLBACK;

    -- ------------------------------------------------------------------------
    -- T5: UPDATE Customer Feedback Rating (4 -> 2) -> AverageRating recomputed
    -- ------------------------------------------------------------------------
    START TRANSACTION;
    INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType)
    VALUES (95001, 92004, 91004, 23, 4, 'Initial 4 star review', NOW(), 'customer');
    INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType)
    VALUES (95002, 92006, 6, 23, 5, '5 star review', NOW(), 'customer');

    -- Update rating from 4 to 2: average becomes (2 + 5) / 2 = 3.50
    UPDATE FEEDBACK SET Rating = 2 WHERE FeedbackID = 95001;

    SELECT AverageRating INTO actual_rating FROM SHIPPER WHERE UserID = 23;
    SELECT 'T5: UPDATE rating from 4 to 2 -> AverageRating recomputed to 3.50' AS Test,
        IF(actual_rating = 3.50, 'PASS', 'FAIL') AS Result,
        actual_rating AS CurrentRating;
    SET failures = failures + IF(actual_rating = 3.50, 0, 1);
    ROLLBACK;

    -- ------------------------------------------------------------------------
    -- T6: UPDATE ShipperID (Reassign feedback from Shipper 23 to Shipper 22)
    -- Both old and new shippers must be recomputed!
    -- ------------------------------------------------------------------------
    START TRANSACTION;
    INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType)
    VALUES (95001, 92004, 91004, 23, 2, 'Review to move', NOW(), 'customer');
    INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType)
    VALUES (95002, 92006, 6, 23, 5, 'Review to keep', NOW(), 'customer');

    -- Reassign 95001 to Shipper 22:
    -- Shipper 23 now has only Rating 5 -> AverageRating = 5.00
    -- Shipper 22 receives Rating 2 -> AverageRating = 2.00
    UPDATE FEEDBACK SET ShipperID = 22 WHERE FeedbackID = 95001;

    SELECT AverageRating INTO actual_rating FROM SHIPPER WHERE UserID = 23;
    SELECT AverageRating INTO start_rating_22 FROM SHIPPER WHERE UserID = 22;

    SELECT 'T6: UPDATE ShipperID -> both old shipper (5.00) and new shipper (2.00) updated' AS Test,
        IF(actual_rating = 5.00 AND start_rating_22 = 2.00, 'PASS', 'FAIL') AS Result,
        CONCAT('OldShipper=', actual_rating, ', NewShipper=', start_rating_22) AS CurrentRating;
    SET failures = failures + IF(actual_rating = 5.00 AND start_rating_22 = 2.00, 0, 1);
    ROLLBACK;

    -- ------------------------------------------------------------------------
    -- T7: DELETE Customer Feedback -> AverageRating recalculated back to 0.00
    -- ------------------------------------------------------------------------
    START TRANSACTION;
    INSERT INTO FEEDBACK (FeedbackID, OrderID, CustomerID, ShipperID, Rating, Comment, CreatedDate, FeedbackType)
    VALUES (95001, 92004, 91004, 23, 5, 'Single customer review', NOW(), 'customer');

    -- Delete the row: Shipper 23 now has 0 customer feedback rows left -> resets to 0.00
    DELETE FROM FEEDBACK WHERE FeedbackID = 95001;

    SELECT AverageRating INTO actual_rating FROM SHIPPER WHERE UserID = 23;
    SELECT 'T7: DELETE customer feedback -> AverageRating resets to 0.00' AS Test,
        IF(actual_rating = 0.00, 'PASS', 'FAIL') AS Result,
        actual_rating AS CurrentRating;
    SET failures = failures + IF(actual_rating = 0.00, 0, 1);
    ROLLBACK;

    -- ------------------------------------------------------------------------
    -- Final Summary
    -- ------------------------------------------------------------------------
    SELECT failures AS FailedTests, IF(failures = 0, 'ALL PASS', 'TESTS FAILED') AS Summary;
    IF failures > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Derived attribute trigger tests failed; inspect result sets.';
    END IF;
END$$

DELIMITER ;

CALL tuan_test_trigger2();
DROP PROCEDURE IF EXISTS tuan_test_trigger2;
