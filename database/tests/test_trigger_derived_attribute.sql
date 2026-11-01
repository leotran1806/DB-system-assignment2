-- A2 2.2.2 demo/test template for SHIPPER.AverageRating.
USE parcel_delivery;

-- TODO A: record the starting AverageRating for a shipper.
-- TODO B: INSERT a completed-order FEEDBACK row with FeedbackType='customer'.
--        SELECT SHIPPER.AverageRating; it should be recalculated.
-- TODO C: INSERT a FeedbackType='shipper' row for the same shipper.
--        AverageRating must NOT change because this rating is not by a customer.
-- TODO D: UPDATE a customer's Rating or ShipperID.
--        Recalculate the old/new shipper averages as needed.
-- TODO E: DELETE the customer feedback row.
--        Recalculate AverageRating; it should become 0.00 if no customer ratings remain.
