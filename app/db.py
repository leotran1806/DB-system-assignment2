"""MySQL access helpers used by the application service layer."""
from __future__ import annotations

import re
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


def _friendly_message(err: Error) -> str:
    errno = getattr(err, "errno", None)
    if errno in (2002, 2003, 2005):
        return "Cannot connect to MySQL. Check that the server is running and verify DB_HOST and DB_PORT in .env."
    if errno == 1045:
        return "MySQL authentication failed. Check DB_USER and DB_PASSWORD in .env."
    if errno == 1049:
        return "The configured database does not exist. Run the database scripts and verify DB_NAME in .env."
    if errno == 1146:
        return "A required database table is missing. Run database/01_create_tables.sql first."
    if errno == 1305:
        return "A required stored procedure or function is missing. Run database/04_procedures.sql and database/05_functions.sql."
    if errno == 1644:
        return getattr(err, "msg", "The database rejected the operation.")
    if errno == 1062:
        return "A value that must be unique is already in use (for example, an email, phone number, ID number, or license plate)."
    if errno in (1451, 1217):
        return "This record cannot be removed because other records still reference it."
    if errno == 1452:
        return "A referenced record does not exist. Check the selected user or administrator."
    if errno == 3819:
        return f"The data violates a database CHECK constraint: {getattr(err, 'msg', '')}"
    if errno == 1292:
        return "A date or numeric value has an invalid format."
    return f"MySQL error ({errno}): {getattr(err, 'msg', str(err))}"


def get_connection():
    """Open one connection with a bounded timeout."""
    try:
        conn = mysql.connector.connect(**DB_CONFIG, connection_timeout=5, use_unicode=True)
        # Keep MySQL result decoding and parameter encoding explicitly UTF-8.
        conn.set_charset_collation("utf8mb4", "utf8mb4_unicode_ci")
        return conn
    except Error as err:
        raise DatabaseError(_friendly_message(err), getattr(err, "errno", None)) from err


def call_proc(name: str, args: Iterable[Any] = ()) -> list[dict[str, Any]]:
    """Call a project stored procedure and collect all result-set rows."""
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", name):
        raise ValueError("Invalid stored procedure name.")

    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.callproc(name, list(args))
        rows: list[dict[str, Any]] = []
        for result in cursor.stored_results():
            columns = result.column_names
            rows.extend(dict(zip(columns, row)) for row in result.fetchall())
            result.close()
        conn.commit()
        return rows
    except Error as err:
        if conn is not None and conn.is_connected():
            conn.rollback()
        raise DatabaseError(_friendly_message(err), getattr(err, "errno", None)) from err
    finally:
        if cursor is not None:
            try:
                cursor.close()
            except Error:
                pass
        if conn is not None and conn.is_connected():
            conn.close()


def call_function(name: str, args: Iterable[Any] = ()) -> Any:
    """Call a known project stored function and return its scalar value."""
    if name not in {"fn_ShipperReputation", "fn_ShipperBonus"}:
        raise ValueError("Unknown stored function.")

    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        values = list(args)
        placeholders = ", ".join(["%s"] * len(values))
        cursor.execute(f"SELECT {name}({placeholders})", values)
        row = cursor.fetchone()
        return row[0] if row else None
    except Error as err:
        raise DatabaseError(_friendly_message(err), getattr(err, "errno", None)) from err
    finally:
        if cursor is not None:
            cursor.close()
        if conn is not None and conn.is_connected():
            conn.close()


def query_all(sql: str, args: Iterable[Any] = ()) -> list[dict[str, Any]]:
    """Execute a SELECT statement used for read-only lookup data."""
    if not sql.lstrip().upper().startswith(("SELECT", "WITH")):
        raise ValueError("query_all() only accepts SELECT statements.")

    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(sql, list(args))
        columns = cursor.column_names
        return [dict(zip(columns, row)) for row in cursor.fetchall()]
    except Error as err:
        raise DatabaseError(_friendly_message(err), getattr(err, "errno", None)) from err
    finally:
        if cursor is not None:
            cursor.close()
        if conn is not None and conn.is_connected():
            conn.close()
