"""Service methods for stored-procedure and stored-function reports."""
from __future__ import annotations

from datetime import date
from typing import Any

from db import DatabaseError, call_function, call_proc


def _positive_int(value: Any, label: str) -> int:
    try:
        result = int(value)
    except (TypeError, ValueError):
        raise DatabaseError(f"{label} must be a positive integer.") from None
    if result <= 0:
        raise DatabaseError(f"{label} must be a positive integer.")
    return result


def _date_value(value: Any, label: str) -> date:
    try:
        if not value:
            raise ValueError
        return date.fromisoformat(str(value).strip())
    except (TypeError, ValueError):
        raise DatabaseError(f"{label} must be a valid date.") from None


def _date_range(from_date: Any, to_date: Any) -> tuple[date, date]:
    start = _date_value(from_date, "Start date")
    end = _date_value(to_date, "End date")
    if start > end:
        raise DatabaseError("Start date must be on or before end date.")
    return start, end


def revenue_by_shipper(from_date: str, to_date: str, min_orders: int = 0) -> list[dict[str, Any]]:
    start, end = _date_range(from_date, to_date)
    try:
        threshold = int(min_orders)
    except (TypeError, ValueError):
        raise DatabaseError("Minimum order count must be a non-negative integer.") from None
    if threshold < 0:
        raise DatabaseError("Minimum order count must be a non-negative integer.")
    return call_proc("sp_RevenueByShipper", (start, end, threshold))


def shipper_reputation(shipper_id: int) -> Any:
    return call_function("fn_ShipperReputation", (_positive_int(shipper_id, "Shipper ID"),))


def shipper_bonus(shipper_id: int, from_date: str, to_date: str) -> Any:
    start, end = _date_range(from_date, to_date)
    return call_function(
        "fn_ShipperBonus",
        (_positive_int(shipper_id, "Shipper ID"), start, end),
    )
