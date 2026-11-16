-- ============================================================================
-- 03_triggers.sql | A2 - Section 2.2 (1 point)
-- STARTER FILE: implement one business-constraint trigger set and one
-- derived-attribute trigger set. Test them with the scripts in database/tests.
-- ============================================================================
USE parcel_delivery;

-- ---------------------------------------------------------------------------
-- 2.2.1 BUSINESS CONSTRAINT — Duy: A1 #6 (completed status is final).
-- Replaces the starter suggestion A1 #4 to match Duy's existing implementation.
-- Business constraint 6: a completed order cannot return to another status.
-- UPDATE can violate this rule. INSERT has no OLD status; DELETE is outside it.
-- CHECK cannot compare the previous and new versions of a row.
DELIMITER $$
CREATE TRIGGER trg_order_preserve_completed
BEFORE UPDATE ON DELIVERY_ORDER
FOR EACH ROW
BEGIN
    IF OLD.OrderStatus = 'completed'
       AND NOT (NEW.OrderStatus <=> 'completed') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Completed order cannot change to another status.';
    END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------------

-- 2.2.2 DERIVED ATTRIBUTE CHOSEN FROM A1: SHIPPER.AverageRating
-- Implemented by: Lê Tuấn
-- Definition from A1 (#14): average rating from FEEDBACK submitted by Customers
-- about the shipper. Feedback submitted by the shipper about the customer is excluded.
--
-- DML operations that affect AverageRating:
--   * INSERT into FEEDBACK: when a new customer feedback is added.
--   * UPDATE on FEEDBACK: when Rating, ShipperID, or FeedbackType changes.
--   * DELETE from FEEDBACK: when a customer feedback is removed.
--
-- Formula:
--   AverageRating = ROUND(AVG(Rating), 2) for FeedbackType = 'customer'.
--   COALESCE to 0.00 if no customer feedback records exist.

DELIMITER $$

DROP TRIGGER IF EXISTS trg_feedback_after_insert$$
CREATE TRIGGER trg_feedback_after_insert
AFTER INSERT ON FEEDBACK
FOR EACH ROW
BEGIN
    IF NEW.FeedbackType = 'customer' THEN
        UPDATE SHIPPER
        SET AverageRating = COALESCE((
            SELECT ROUND(AVG(Rating), 2)
            FROM FEEDBACK
            WHERE ShipperID = NEW.ShipperID
              AND FeedbackType = 'customer'
        ), 0.00)
        WHERE UserID = NEW.ShipperID;
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_feedback_after_update$$
CREATE TRIGGER trg_feedback_after_update
AFTER UPDATE ON FEEDBACK
FOR EACH ROW
BEGIN
    -- Case 1: ShipperID reassigned to another shipper
    IF OLD.ShipperID <> NEW.ShipperID THEN
        IF OLD.FeedbackType = 'customer' THEN
            UPDATE SHIPPER
            SET AverageRating = COALESCE((
                SELECT ROUND(AVG(Rating), 2)
                FROM FEEDBACK
                WHERE ShipperID = OLD.ShipperID
                  AND FeedbackType = 'customer'
            ), 0.00)
            WHERE UserID = OLD.ShipperID;
        END IF;

        IF NEW.FeedbackType = 'customer' THEN
            UPDATE SHIPPER
            SET AverageRating = COALESCE((
                SELECT ROUND(AVG(Rating), 2)
                FROM FEEDBACK
                WHERE ShipperID = NEW.ShipperID
                  AND FeedbackType = 'customer'
            ), 0.00)
            WHERE UserID = NEW.ShipperID;
        END IF;
    ELSE
        -- Case 2: Same ShipperID, but Rating or FeedbackType changed
        IF (OLD.Rating <> NEW.Rating) OR (OLD.FeedbackType <> NEW.FeedbackType) THEN
            UPDATE SHIPPER
            SET AverageRating = COALESCE((
                SELECT ROUND(AVG(Rating), 2)
                FROM FEEDBACK
                WHERE ShipperID = NEW.ShipperID
                  AND FeedbackType = 'customer'
            ), 0.00)
            WHERE UserID = NEW.ShipperID;
        END IF;
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_feedback_after_delete$$
CREATE TRIGGER trg_feedback_after_delete
AFTER DELETE ON FEEDBACK
FOR EACH ROW
BEGIN
    IF OLD.FeedbackType = 'customer' THEN
        UPDATE SHIPPER
        SET AverageRating = COALESCE((
            SELECT ROUND(AVG(Rating), 2)
            FROM FEEDBACK
            WHERE ShipperID = OLD.ShipperID
              AND FeedbackType = 'customer'
        ), 0.00)
        WHERE UserID = OLD.ShipperID;
    END IF;
END$$

DELIMITER ;
