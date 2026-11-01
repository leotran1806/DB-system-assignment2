-- A2 2.2.1 demo/test template. Complete after implementing trigger(s).
USE parcel_delivery;

-- TODO A: choose an OrderID that has no accepted assignment.
-- INSERT a valid accepted assignment. Expected: succeeds.

-- TODO B: INSERT a second accepted assignment for the same OrderID.
-- Expected: trigger rejects it with a specific SQLSTATE 45000 message.

-- TODO C: choose an existing offered/rejected assignment and UPDATE it to
-- AssignmentStatus='accepted' while another accepted assignment exists.
-- Expected: trigger rejects the UPDATE.

-- TODO D: attempt an UPDATE that does not create a duplicate active assignment.
-- Expected: succeeds.

-- TODO: SELECT from DELIVERY_ASSIGNMENT after each valid test to verify state.
-- Run invalid tests individually because SIGNAL intentionally stops the statement.
