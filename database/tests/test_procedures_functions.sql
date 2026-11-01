-- A2 demo script template for 2.1, 2.3 and 2.4.
USE parcel_delivery;

-- 2.1 CRUD procedure demonstrations:
-- TODO: CALL sp_InsertShipper(...) with valid data; expect success.
-- TODO: CALL sp_InsertShipper(...) with duplicate/invalid NIN; expect a specific error.
-- TODO: CALL sp_UpdateShipper(...) with valid data; expect updated row.
-- TODO: CALL sp_UpdateShipper(...) with invalid status or duplicate NIN; expect error.
-- TODO: CALL sp_DeleteShipper(...) for a record eligible for deletion; expect success.
-- TODO: CALL sp_DeleteShipper(...) for a shipper with history; expect the documented
--       reject/deactivate behavior. Run each expected-error CALL separately.

-- 2.3 query procedure demonstrations:
-- TODO: CALL sp_ListShippers(search, availability, account_status, vehicle_type, sort_by).
-- TODO: CALL sp_RevenueByShipper(from_date, to_date, minimum_order_count).

-- 2.4 function demonstrations:
-- TODO: SELECT fn_ShipperReputation(shipper_id);
-- TODO: SELECT fn_ShipperBonus(shipper_id, from_date, to_date);

-- TODO: capture expected outputs and explain each test case in the presentation.
