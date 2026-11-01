"""Service layer for A2 sections 2.3 and 2.4, used by the Reports screen."""
from __future__ import annotations

from typing import Any

from db import FeatureNotImplementedError, call_function, call_proc


def revenue_by_shipper(from_date: str, to_date: str, min_orders: int = 0) -> list[dict[str, Any]]:
    """Call query-only procedure `sp_RevenueByShipper` (A2 section 2.3).

    IMPLEMENT THIS FUNCTION:
    1. Validate both dates and require from_date <= to_date.
    2. Validate min_orders as a non-negative integer.
    3. Call db.call_proc("sp_RevenueByShipper", (...)) with these values.
    4. Return rows. The SQL procedure must JOIN at least two tables and include
       WHERE, aggregate functions, GROUP BY, HAVING and ORDER BY.
    5. The procedure must contain SELECT/query statements only; no DML.
    """
    raise FeatureNotImplementedError(
        "Báo cáo doanh thu chưa được cài đặt. Hãy hoàn thiện revenue_by_shipper() "
        "và sp_RevenueByShipper."
    )


def shipper_reputation(shipper_id: int) -> Any:
    """Call `fn_ShipperReputation` (A2 section 2.4).

    IMPLEMENT THIS FUNCTION:
    1. Parse and validate shipper_id as a positive integer.
    2. Call db.call_function("fn_ShipperReputation", (shipper_id,)).
    3. Return the scalar result for display.
    4. In MySQL, the function must validate that the shipper exists, open a
       cursor for customer-submitted feedback only, use a LOOP/IF to aggregate
       ratings, close the cursor, and return the required result.
    """
    raise FeatureNotImplementedError(
        "Hàm điểm uy tín chưa được cài đặt. Hãy hoàn thiện shipper_reputation() "
        "và fn_ShipperReputation."
    )


def shipper_bonus(shipper_id: int, from_date: str, to_date: str) -> Any:
    """Call `fn_ShipperBonus` (A2 section 2.4).

    IMPLEMENT THIS FUNCTION:
    1. Validate shipper_id > 0 and both dates; require from_date <= to_date.
    2. Call db.call_function("fn_ShipperBonus", (shipper_id, from_date, to_date)).
    3. In MySQL, validate the shipper and period, declare a cursor over that
       shipper's SHIPPER_EARNING rows for the period, and loop through the rows.
    4. Compute each net earning as DeliveryFee - PlatformCommission (or use the
       stored derived value only if A1's schema explicitly defines it).
    5. Use IF/ELSEIF to select the bonus rate. The team must justify and document
       the thresholds/rates because A1 does not specify a bonus policy.
    6. Close the cursor and return the computed numeric amount.
    """
    raise FeatureNotImplementedError(
        "Hàm tính thưởng chưa được cài đặt. Hãy hoàn thiện shipper_bonus() "
        "và fn_ShipperBonus."
    )
