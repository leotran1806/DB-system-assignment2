"""Flask application entry point. Run with ``python app/app.py``."""
from __future__ import annotations

import sys
from pathlib import Path

from flask import Flask, redirect, url_for

APP_DIR = Path(__file__).resolve().parent
if str(APP_DIR) not in sys.path:
    sys.path.insert(0, str(APP_DIR))

from config import DEBUG, PORT, SECRET_KEY  # noqa: E402
from routes import reports, shippers  # noqa: E402


def create_app() -> Flask:
    app = Flask(__name__)
    app.config.update(
        SECRET_KEY=SECRET_KEY,
        SESSION_COOKIE_HTTPONLY=True,
        SESSION_COOKIE_SAMESITE="Lax",
    )
    app.register_blueprint(shippers.bp)
    app.register_blueprint(reports.bp)

    @app.get("/")
    def home():
        return redirect(url_for("shippers.index"))

    @app.template_filter("vnd")
    def format_vnd(value):
        try:
            return f"₫{float(value):,.0f}"
        except (TypeError, ValueError):
            return value if value is not None else "—"

    @app.template_filter("date_only")
    def date_only(value):
        return value.strftime("%Y-%m-%d") if hasattr(value, "strftime") else (value or "")

    @app.errorhandler(404)
    def not_found(_error):
        return "Page not found", 404

    return app


app = create_app()

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=PORT, debug=DEBUG)
