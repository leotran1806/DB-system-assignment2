"""Routes for the SHIPPER management screen (A2 sections 3.1 and 3.2)."""
from flask import Blueprint, flash, redirect, render_template, request, url_for

from db import DatabaseError, FeatureNotImplementedError
from services import shipper_service as service

bp = Blueprint("shippers", __name__)


@bp.route("/shippers", methods=["GET", "POST"])
def index():
    """Render the combined create/list/update/delete screen.

    TODO when implementing the app:
    - POST on this page is the INSERT action; validate required form fields and
      call service.insert_shipper(). Never execute SQL in the route.
    - GET calls service.list_shippers() which must call sp_ListShippers.
    - Pass search/filter/sort values back to the template so they stay selected.
    - Catch DatabaseError and FeatureNotImplementedError and display clear,
      specific flash messages without breaking the page shell.
    """
    filters = {
        "search": request.args.get("search", ""),
        "availability": request.args.get("availability", ""),
        "account_status": request.args.get("account_status", ""),
        "vehicle_type": request.args.get("vehicle_type", ""),
        "sort": request.args.get("sort", "name"),
    }

    if request.method == "POST":
        try:
            service.insert_shipper(request.form)
            flash("Đã thêm Shipper.", "success")
            return redirect(url_for("shippers.index"))
        except (DatabaseError, FeatureNotImplementedError, ValueError) as err:
            flash(getattr(err, "message", str(err)), "warning")

    rows = []
    try:
        rows = service.list_shippers(**filters)
    except (DatabaseError, FeatureNotImplementedError) as err:
        flash(getattr(err, "message", str(err)), "info")

    return render_template(
        "shippers/list.html",
        rows=rows,
        filters=filters,
        sort_options=service.SORT_OPTIONS,
        implementation_ready=False,
    )


@bp.post("/shippers/<int:user_id>/update")
def update(user_id: int):
    """Handle an inline UPDATE action from the shipper list.

    TODO: call service.update_shipper(user_id, request.form), catch validation
    and DB errors, flash a precise message, then redirect to the filtered list.
    The stored procedure, not this route, must perform the UPDATE.
    """
    try:
        service.update_shipper(user_id, request.form)
        flash("Đã cập nhật Shipper.", "success")
    except (DatabaseError, FeatureNotImplementedError, ValueError) as err:
        flash(getattr(err, "message", str(err)), "warning")
    return redirect(url_for("shippers.index"))


@bp.post("/shippers/<int:user_id>/delete")
def delete(user_id: int):
    """Handle a DELETE action from the list.

    TODO: call service.delete_shipper(user_id), display the procedure's result,
    and distinguish physical deletion from deactivation if that is your chosen
    SQL policy. Never delete the row directly in this route.
    """
    try:
        result = service.delete_shipper(user_id)
        flash(f"Kết quả xóa Shipper: {result}", "success")
    except (DatabaseError, FeatureNotImplementedError, ValueError) as err:
        flash(getattr(err, "message", str(err)), "warning")
    return redirect(url_for("shippers.index"))
