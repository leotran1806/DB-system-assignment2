"""Application configuration.

This module only reads configuration. It does not connect to MySQL.
"""
from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv

PROJECT_ROOT = Path(__file__).resolve().parent.parent
load_dotenv(PROJECT_ROOT / ".env")

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "127.0.0.1"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "parcel_delivery"),
    "charset": "utf8mb4",
    "collation": "utf8mb4_unicode_ci",
}

SECRET_KEY = os.getenv("FLASK_SECRET_KEY", "local-development-key-change-me")
DEBUG = os.getenv("FLASK_DEBUG", "true").strip().lower() in {"1", "true", "yes", "on"}
PORT = int(os.getenv("PORT", "5000"))
