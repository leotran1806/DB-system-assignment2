"""Application service methods for shipper management."""
from __future__ import annotations

import re
from datetime import date
from decimal import Decimal, InvalidOperation
from typing import Any

from db import DatabaseError, call_proc, query_all

SORT_OPTIONS = {
    "name": "Tên tài xế (A-Z)",
    "join_date": "Ngày tham gia (mới nhất)",
    "availability": "Trạng thái làm việc",
    "rating": "Điểm đánh giá",
}

AVAILABILITY_VALUES = ("available", "busy", "offline")
ACCOUNT_STATUS_VALUES = ("active", "suspended", "closed")
VEHICLE_TYPE_VALUES = ("motorbike", "car", "van", "truck")
LICENSE_TYPE_VALUES = ("A1", "A2", "B1", "B2", "C")
SEARCH_MAX_LENGTH = 100


def _clean_text(value: Any) -> str | None:
    if value is None:
        return None
    value = str(value).strip()
    return value or None


def _required(form, key: str, label: str) -> str:
    value = _clean_text(form.get(key))
    if value is None:
        raise DatabaseError(f"{label} is required.")
    return value


def _positive_int(value: Any, label: str) -> int:
    try:
        parsed = int(value)
    except (TypeError, ValueError):
        raise DatabaseError(f"{label} must be a positive integer.") from None
    if parsed <= 0:
        raise DatabaseError(f"{label} must be a positive integer.")
    return parsed


def _date_value(value: Any, label: str) -> date:
    text = _clean_text(value)
    if not text:
        raise DatabaseError(f"{label} is required.")
    try:
        return date.fromisoformat(text)
    except ValueError:
        raise DatabaseError(f"{label} must be a valid date.") from None


def _decimal_value(value: Any, label: str) -> Decimal:
    text = _clean_text(value)
    try:
        number = Decimal(text) if text is not None else Decimal("NaN")
    except InvalidOperation:
        number = Decimal("NaN")
    if not number.is_finite() or number <= 0:
        raise DatabaseError(f"{label} must be a number greater than zero.")
    return number


def _validate_choice(value: Any, allowed: tuple[str, ...], label: str) -> str | None:
    """Normalize an optional filter and ensure it is one of `allowed` (or empty)."""
    cleaned = _clean_text(value)
    if cleaned is None:
        return None
    if cleaned not in allowed:
        raise DatabaseError(f"{label} không hợp lệ. Chọn một trong: {', '.join(allowed)}.")
    return cleaned


def list_shippers(
    search: str | None = None,
    availability: str | None = None,
    account_status: str | None = None,
    vehicle_type: str | None = None,
    sort: str = "name",
) -> list[dict[str, Any]]:
    search = _clean_text(search)
    if search is not None and len(search) > SEARCH_MAX_LENGTH:
        raise DatabaseError(
            f"Từ khóa tìm kiếm tối đa {SEARCH_MAX_LENGTH} ký tự."
        )
    availability = _validate_choice(
        availability, AVAILABILITY_VALUES, "Trạng thái làm việc"
    )
    account_status = _validate_choice(
        account_status, ACCOUNT_STATUS_VALUES, "Trạng thái tài khoản"
    )
    vehicle_type = _validate_choice(vehicle_type, VEHICLE_TYPE_VALUES, "Loại xe")
    sort_key = _clean_text(sort) or "name"
    if sort_key not in SORT_OPTIONS:
        raise DatabaseError(
            "Tiêu chí sắp xếp không hợp lệ. Chọn một trong: "
            + ", ".join(SORT_OPTIONS)
            + "."
        )

    # Filtering and ORDER BY are done inside the stored procedure (A2 2.3).
    # Last argument (UserID) is NULL = do not restrict to a single shipper.
    return call_proc(
        "sp_ListShippers",
        [search, availability, account_status, vehicle_type, sort_key, None],
    )


def insert_shipper(form) -> int | None:
    """Create USER, SHIPPER, SHIPPER_LICENSE and VEHICLE in one SQL transaction."""
    email = _required(form, "email", "Email")
    phone = _required(form, "phone", "Phone number")
    password = _required(form, "password", "Password")
    date_of_birth = _date_value(form.get("date_of_birth"), "Date of birth")
    gender = _validate_choice(form.get("gender"), ("male", "female"), "gender")
    first_name = _required(form, "first_name", "First name")
    last_name = _required(form, "last_name", "Last name")
    national_id = _required(form, "national_id", "National ID")
    admin_id = _positive_int(form.get("managed_by_admin_id"), "Managing administrator ID")
    license_number = _required(form, "license_number", "License number")
    license_type = _validate_choice(form.get("license_type"), LICENSE_TYPE_VALUES, "license type")
    license_issue_date = _date_value(form.get("license_issue_date"), "License issue date")
    license_expiry_date = _date_value(form.get("license_expiry_date"), "License expiry date")
    brand = _required(form, "brand", "Vehicle brand")
    model = _required(form, "model", "Vehicle model")
    license_plate = _required(form, "license_plate", "License plate").upper()
    color = _required(form, "color", "Vehicle color")
    maximum_load = _decimal_value(form.get("maximum_load"), "Maximum load")
    vehicle_type = _validate_choice(form.get("vehicle_type"), VEHICLE_TYPE_VALUES, "vehicle type")

    if not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", email):
        raise DatabaseError("Enter a valid email address.")
    if not re.fullmatch(r"0\d{9}", phone):
        raise DatabaseError("Phone number must contain 10 digits and start with 0.")
    if len(password) < 8:
        raise DatabaseError("Password must contain at least 8 characters.")
    if gender is None or license_type is None or vehicle_type is None:
        raise DatabaseError("Please complete all required selection fields.")
    if license_issue_date >= license_expiry_date:
        raise DatabaseError("License expiry date must be after the issue date.")

    rows = call_proc("sp_InsertShipper", (
        email, phone, password, date_of_birth, gender, first_name, last_name,
        national_id, admin_id, license_number, license_type,
        license_issue_date, license_expiry_date, brand, model, license_plate,
        color, maximum_load, vehicle_type,
    ))
    if not rows:
        return None
    return rows[0].get("NewShipperID") or rows[0].get("NewUserID")


def update_shipper(user_id: int, form) -> None:
    shipper_id = _positive_int(user_id, "Shipper ID")
    national_id = _required(form, "national_id", "National ID")
    availability = _validate_choice(form.get("availability_status"), AVAILABILITY_VALUES, "availability status")
    join_date = _date_value(form.get("join_date"), "Join date")
    admin_id = _positive_int(form.get("managed_by_admin_id"), "Managing administrator ID")
    if availability is None:
        raise DatabaseError("Availability status is required.")
    call_proc("sp_UpdateShipper", (shipper_id, national_id, availability, join_date, admin_id))


def delete_shipper(user_id: int) -> str:
    shipper_id = _positive_int(user_id, "Shipper ID")
    rows = call_proc("sp_DeleteShipper", (shipper_id,))
    return str(rows[0].get("Action", "deactivated")) if rows else "deactivated"


def get_shipper(user_id: int) -> dict[str, Any] | None:
    try:
        shipper_id = int(user_id)
    except (TypeError, ValueError):
        raise DatabaseError("UserID phải là số nguyên dương.") from None
    if shipper_id <= 0:
        raise DatabaseError("UserID phải là số nguyên dương.")

    rows = call_proc(
        "sp_ListShippers", [None, None, None, None, "name", shipper_id]
    )
    return rows[0] if rows else None

# Chỗ này Minh lại hàm list_admins() của em nó không hiển thị gì hết (cái code anh để đây mới hiện á)
def list_admins() -> list[dict[str, Any]]:
    return query_all(
        "SELECT a.UserID AS UserID, "
        "       CONCAT_WS(' ', u.LastName, u.FirstName) AS FullName, "
        "       u.AccountStatus AS AccountStatus "
        "FROM ADMIN a JOIN `USER` u ON u.UserID = a.UserID "
        "ORDER BY u.AccountStatus, u.LastName, u.FirstName, a.UserID"
    )
