"""HTTP routes for stored procedure and function reports."""
from flask import Blueprint, flash, render_template, request

from db import DatabaseError
from services import report_service, shipper_service

bp = Blueprint("reports", __name__)


@bp.route("/reports", methods=["GET", "POST"])
def index():
    context = {
        "shippers": [],
        "revenue": None,
        "reputation": None,
        "bonus": None,
        "form_data": {},
        "active_action": None,
    }
    try:
        context["shippers"] = shipper_service.list_shippers(sort="name")
    except DatabaseError as err:
        flash(err.message, "info")

    if request.method == "POST":
        context["form_data"] = request.form.to_dict()
        action = request.form.get("action")
        context["active_action"] = action
        try:
            if action == "revenue":
                context["revenue"] = report_service.revenue_by_shipper(
                    request.form.get("from_date"),
                    request.form.get("to_date"),
                    request.form.get("min_orders", "0"),
                )
            elif action == "reputation":
                context["reputation"] = report_service.shipper_reputation(
                    request.form.get("shipper_id")
                )
            elif action == "bonus":
                context["bonus"] = report_service.shipper_bonus(
                    request.form.get("shipper_id"),
                    request.form.get("from_date"),
                    request.form.get("to_date"),
                )
            else:
                flash("Invalid report action.", "warning")
        except (DatabaseError, ValueError) as err:
            flash(getattr(err, "message", str(err)), "danger")

    return render_template("reports/index.html", **context)
