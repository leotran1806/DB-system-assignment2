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
-- Definition from A1: average rating from FEEDBACK submitted by Customers about
-- the shipper. Feedback submitted by the shipper about the customer is excluded.
--
-- DML operations that affect AverageRating:
--   * INSERT into FEEDBACK (a customer feedback is added).
--   * UPDATE FEEDBACK (Rating, ShipperID or FeedbackType changes).
--   * DELETE from FEEDBACK (a customer feedback is removed).
--
-- TODO:
-- 1. Ensure SHIPPER has a stored AverageRating column (e.g. DECIMAL(3,2)).
-- 2. Create AFTER INSERT, AFTER UPDATE and AFTER DELETE triggers on FEEDBACK.
-- 3. Recalculate with AVG(Rating) where ShipperID = the affected shipper and
--    FeedbackType='customer'; use COALESCE(..., 0.00) when no ratings remain.
-- 4. For UPDATE, recalculate both OLD.ShipperID and NEW.ShipperID if the shipper
--    association changes. If FeedbackType changes, recalculate affected shipper.
-- 5. Do not include FeedbackType='shipper' in the average.
-- 6. Add a test that inserts, changes and deletes feedback and checks the stored
--    AverageRating after each operation.
--
-- Template (complete the TODOs and remove the comment markers before running):
-- DELIMITER $$
-- CREATE TRIGGER trg_feedback_ai
-- AFTER INSERT ON FEEDBACK
-- FOR EACH ROW
-- BEGIN
--     -- TODO: UPDATE SHIPPER SET AverageRating = (SELECT COALESCE(AVG(Rating),0)
--     --        FROM FEEDBACK WHERE ShipperID=NEW.ShipperID
--     --        AND FeedbackType='customer') WHERE UserID=NEW.ShipperID;
-- END$$
--
-- CREATE TRIGGER trg_feedback_au
-- AFTER UPDATE ON FEEDBACK
-- FOR EACH ROW
-- BEGIN
--     -- TODO: recalculate OLD.ShipperID and NEW.ShipperID when applicable.
-- END$$
--
-- CREATE TRIGGER trg_feedback_ad
-- AFTER DELETE ON FEEDBACK
-- FOR EACH ROW
-- BEGIN
--     -- TODO: recalculate OLD.ShipperID.
-- END$$
-- DELIMITER ;
