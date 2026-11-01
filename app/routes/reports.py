"""Routes for the additional A2 procedure/function demonstration (section 3.3)."""
from flask import Blueprint, flash, render_template, request

from db import DatabaseError, FeatureNotImplementedError
from services import report_service
from services import shipper_service

bp = Blueprint("reports", __name__)


@bp.route("/reports", methods=["GET", "POST"])
def index():
    """Display procedure/function demo forms and their results.

    TODO:
    - For action='revenue', validate period/threshold and call the second
      query procedure from 2.3 through report_service.revenue_by_shipper().
    - For action='reputation', call fn_ShipperReputation through the service.
    - For action='bonus', call fn_ShipperBonus through the service.
    - Keep SQL out of this route. Show empty-result and input-validation
      messages separately from database connection errors.
    """
    context = {
        "shippers": [],
        "revenue": None,
        "reputation": None,
        "bonus": None,
        "form_data": {},
    }
    try:
        context["shippers"] = shipper_service.list_shippers()
    except (DatabaseError, FeatureNotImplementedError):
        # The form remains accessible even before the list procedure exists.
        context["shippers"] = []

    if request.method == "POST":
        context["form_data"] = request.form.to_dict()
        action = request.form.get("action")
        try:
            if action == "revenue":
                context["revenue"] = report_service.revenue_by_shipper(
                    request.form.get("from_date", ""),
                    request.form.get("to_date", ""),
                    request.form.get("min_orders", "0"),
                )
            elif action == "reputation":
                context["reputation"] = report_service.shipper_reputation(
                    request.form.get("shipper_id", "")
                )
            elif action == "bonus":
                context["bonus"] = report_service.shipper_bonus(
                    request.form.get("shipper_id", ""),
                    request.form.get("from_date", ""),
                    request.form.get("to_date", ""),
                )
            else:
                flash("Thao tác báo cáo không hợp lệ.", "warning")
        except (DatabaseError, FeatureNotImplementedError, ValueError) as err:
            flash(getattr(err, "message", str(err)), "warning")

    return render_template("reports/index.html", **context)
