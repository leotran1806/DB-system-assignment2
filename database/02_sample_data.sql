-- ============================================================================
-- 02_sample_data.sql | A2 - Section 1.2 (1 point)
-- STARTER FILE: add meaningful INSERT statements. Do not leave this file empty.
-- Requirement: at least 5 rows in EACH of the 16 tables.
-- ============================================================================
USE parcel_delivery;

-- IMPORTANT: respect foreign-key dependency order. A recommended order is:
-- 1 USER (insert enough distinct accounts for Customer, Shipper and Admin roles)
-- 2 ADMIN, CUSTOMER, SHIPPER
-- 3 SHIPPER_LICENSE, VEHICLE, PROMOTION
-- 4 DELIVERY_ORDER
-- 5 PACKAGE, DELIVERY_ASSIGNMENT, ORDER_STATUS_LOG, PAYMENT, APPLIED_TO
-- 6 POINT_TRANSACTION, FEEDBACK, SHIPPER_EARNING
--
-- For EVERY table below, prepare at least FIVE meaningful rows, not five copies
-- of the same values. Include different statuses and boundary cases so the
-- CHECK constraints, triggers, procedures and functions can be demonstrated.

-- TODO 1: INSERT >= 5 USER rows.
--        Include valid unique emails/phones and accounts in active/suspended/
--        closed states, while preserving the A1 disjoint/total role specialization.

-- TODO 2: INSERT >= 5 ADMIN rows.
--        Make EmployeeCode unique. If using Supervisor_ID, insert supervisors
--        before subordinate admins and avoid self-supervision/cycles.

-- TODO 3: INSERT >= 5 CUSTOMER rows.
--        Include different non-negative LoyaltyPoint balances.

-- TODO 4: INSERT >= 5 SHIPPER rows.
--        Include available/busy/offline states and valid unique NIN values.
--        If AverageRating is stored, seed it consistently with FEEDBACK or let
--        the derived-attribute trigger calculate it after feedback is inserted.

-- TODO 5: INSERT >= 5 SHIPPER_LICENSE rows.
--        Every ShipperID must exist. Include license types that can be used to
--        demonstrate vehicle compatibility and rejected incompatible cases.

-- TODO 6: INSERT >= 5 VEHICLE rows.
--        Each ShipperID must be unique if the 1:1 relationship is enforced.
--        Include motorbike/car/van/truck, positive load and unique plate numbers.

-- TODO 7: INSERT >= 5 PROMOTION rows.
--        Include percentage/fixed discounts, active/inactive/expired states,
--        valid date windows, minimum values and distinct usage limits.

-- TODO 8: INSERT >= 5 DELIVERY_ORDER rows.
--        Use existing CustomerID values. Include placed/accepted/delivering/
--        completed/cancelled cases. Every cancelled row needs a reason. Respect
--        CompleteDate rules. If derived fee/discount/price are stored, seed them
--        consistently or allow triggers to derive them.

-- TODO 9: INSERT >= 5 PACKAGE rows.
--        Link to existing orders; use meaningful descriptions/categories and
--        valid positive dimensions/weight. Ensure at least one package per order.

-- TODO 10: INSERT >= 5 DELIVERY_ASSIGNMENT rows.
--         Include offered/rejected/accepted/completed statuses and valid dates.
--         Do not seed two simultaneously active assignments for one order.
--
-- TODO 11: INSERT >= 5 ORDER_STATUS_LOG rows.
--         The latest status for each order must match DELIVERY_ORDER.OrderStatus.
--
-- TODO 12: INSERT >= 5 PAYMENT rows.
--         Each OrderID must be unique if the one-payment-per-order rule is used.
--         Use values allowed by the CHECK constraints.
--
-- TODO 13: INSERT >= 5 APPLIED_TO rows.
--         Use existing orders/promotions. Discounts must be correct and total
--         discounts must not exceed DeliveryFee. Respect promotion validity.
--
-- TODO 14: INSERT >= 5 POINT_TRANSACTION rows.
--         Include both earn and redeem transactions; no resulting balance may
--         become negative. Link order IDs only when appropriate.
--
-- TODO 15: INSERT >= 5 FEEDBACK rows.
--         Use completed orders only; Rating must be integer 1..5. Include both
--         Customer-to-Shipper and Shipper-to-Customer feedback types.
--
-- TODO 16: INSERT >= 5 SHIPPER_EARNING rows.
--         Use completed orders and the shipper who completed each order.
--         NetEarning must equal DeliveryFee - PlatformCommission. Include paid
--         and pending payouts; paid rows need valid PayoutDate values.

-- TODO: after inserting all rows, write SELECT COUNT(*) checks for all 16
-- tables and verify every count is >= 5 before the presentation.
