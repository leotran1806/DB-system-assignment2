"""Flask application entry point.

Run from the project root with: python app/app.py
The home page is available even before MySQL is configured or SQL is complete.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

from flask import Flask, redirect, url_for

APP_DIR = Path(__file__).resolve().parent
if str(APP_DIR) not in sys.path:
    sys.path.insert(0, str(APP_DIR))

from config import DEBUG, PORT, SECRET_KEY  # noqa: E402
from routes import reports, shippers  # noqa: E402


def create_app() -> Flask:
    """Create and configure the Flask application.

    TODO (optional): add CSRF protection, authentication/authorization and
    production logging if the team decides these are within its project scope.
    They are not required by the three specific interface criteria in A2.
    """
    app = Flask(__name__)
    app.config["SECRET_KEY"] = SECRET_KEY
    app.register_blueprint(shippers.bp)
    app.register_blueprint(reports.bp)

    @app.get("/")
    def home():
        """Keep the root URL useful by opening the basic Admin screen."""
        return redirect(url_for("shippers.index"))

    @app.template_filter("vnd")
    def format_vnd(value):
        """Format numeric values as Vietnamese đồng for report output."""
        try:
            return f"{float(value):,.0f}".replace(",", ".") + " đ"
        except (TypeError, ValueError):
            return value if value is not None else "—"

    return app


app = create_app()

if __name__ == "__main__":
    # Host 127.0.0.1 keeps the starter local to the developer's computer.
    app.run(host="127.0.0.1", port=PORT, debug=DEBUG)
