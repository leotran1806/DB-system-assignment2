"""Reusable MySQL helpers.

The connection helpers below are infrastructure, not the assignment's business
logic. Complete the SQL procedures/functions first, then call them from services.
All INSERT/UPDATE/DELETE operations in the application must use call_proc().
Direct query_all() calls are reserved for SELECT-only lookup data.
"""
from __future__ import annotations

from typing import Any, Iterable

import mysql.connector
from mysql.connector import Error

from config import DB_CONFIG


class DatabaseError(RuntimeError):
    """Database error translated to a message suitable for the UI."""

    def __init__(self, message: str, errno: int | None = None):
        super().__init__(message)
        self.message = message
        self.errno = errno


class FeatureNotImplementedError(RuntimeError):
    """Raised by starter service methods until the student implements them."""


def get_connection():
    """Open a MySQL connection.

    TODO (only if needed): add connection pooling or explicit connection timeouts.
    Keep credentials in .env; never hard-code them in this file.
    """
    try:
        return mysql.connector.connect(**DB_CONFIG)
    except Error as err:
        raise DatabaseError(_friendly_message(err), err.errno) from err


def _friendly_message(err: Error) -> str:
    """Convert common MySQL errors into clear Vietnamese UI messages."""
    errno = getattr(err, "errno", None)
    if errno in (2002, 2003):
        return "Không kết nối được MySQL. Hãy kiểm tra MySQL Server, DB_HOST và DB_PORT trong .env."
    if errno == 1045:
        return "Sai tài khoản hoặc mật khẩu MySQL. Hãy kiểm tra DB_USER và DB_PASSWORD trong .env."
    if errno == 1049:
        return "Không tìm thấy database. Hãy tạo database parcel_delivery và hoàn thành các script SQL trước."
    if errno == 1146:
        return "Không tìm thấy bảng cần truy vấn. Hãy hoàn thành database/01_create_tables.sql."
    if errno == 1305:
        return "Không tìm thấy stored procedure/function. Hãy hoàn thành và chạy các script SQL tương ứng."
    if errno == 1644:
        return err.msg
    if errno == 1062:
        return "Dữ liệu bị trùng với một giá trị đã tồn tại (ví dụ email, số điện thoại hoặc mã định danh)."
    if errno in (1451, 1217):
        return "Không thể xóa bản ghi vì dữ liệu đang được bảng khác tham chiếu."
    if errno == 1452:
        return "Khóa ngoại không hợp lệ: bản ghi được tham chiếu không tồn tại."
    if errno == 3819:
        return f"Dữ liệu vi phạm CHECK constraint: {err.msg}"
    return f"Lỗi MySQL ({errno}): {err.msg}"


def call_proc(name: str, args: Iterable[Any] = ()) -> list[dict[str, Any]]:
    """Call a stored procedure and return all rows from its result sets.

    Use this helper for the 2.1 CRUD procedures and the 2.3 query procedures.
    The service layer must validate/normalize Python inputs before calling it.
    """
    conn = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.callproc(name, list(args))
        rows: list[dict[str, Any]] = []
        for result in cursor.stored_results():
            columns = result.column_names
            rows.extend(dict(zip(columns, row)) for row in result.fetchall())
        conn.commit()
        cursor.close()
        return rows
    except DatabaseError:
        if conn is not None and conn.is_connected():
            conn.rollback()
        raise
    except Error as err:
        if conn is not None and conn.is_connected():
            conn.rollback()
        raise DatabaseError(_friendly_message(err), err.errno) from err
    finally:
        if conn is not None and conn.is_connected():
            conn.close()


def call_function(name: str, args: Iterable[Any] = ()) -> Any:
    """Call a stored function through SELECT and return its scalar result.

    Only use a function name authored in this project; do not pass a user value
    as the function name. Values are passed separately as bound parameters.
    """
    conn = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        values = list(args)
        placeholders = ", ".join(["%s"] * len(values))
        cursor.execute(f"SELECT {name}({placeholders})", values)
        row = cursor.fetchone()
        cursor.close()
        return row[0] if row else None
    except DatabaseError:
        raise
    except Error as err:
        raise DatabaseError(_friendly_message(err), err.errno) from err
    finally:
        if conn is not None and conn.is_connected():
            conn.close()


def query_all(sql: str, args: Iterable[Any] = ()) -> list[dict[str, Any]]:
    """Execute a SELECT-only query for lookup lists (e.g. admin dropdowns).

    Do not use this helper for INSERT, UPDATE or DELETE. Those operations must
    call stored procedures to match the assignment's requirement.
    """
    conn = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(sql, list(args))
        columns = cursor.column_names
        rows = [dict(zip(columns, row)) for row in cursor.fetchall()]
        cursor.close()
        return rows
    except DatabaseError:
        raise
    except Error as err:
        raise DatabaseError(_friendly_message(err), err.errno) from err
    finally:
        if conn is not None and conn.is_connected():
            conn.close()
