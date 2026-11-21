"""HTTP routes for shipper administration."""
from flask import Blueprint, flash, redirect, render_template, request, url_for

from db import DatabaseError
from services import shipper_service as service

bp = Blueprint("shippers", __name__)


def _list_url():
    filters = {
        key: request.form.get(key)
        for key in ("search", "availability", "account_status", "vehicle_type", "sort")
        if request.form.get(key)
    }
    return url_for("shippers.index", **filters)


@bp.route("/shippers", methods=["GET", "POST"])
def index():
    filters = {
        "search": request.args.get("search", ""),
        "availability": request.args.get("availability", ""),
        "account_status": request.args.get("account_status", ""),
        "vehicle_type": request.args.get("vehicle_type", ""),
        "sort": request.args.get("sort", "name"),
    }
    form_data = {}

    if request.method == "POST":
        form_data = request.form.to_dict()
        try:
            new_id = service.insert_shipper(request.form)
            flash(f"Shipper account created successfully (User ID: {new_id}).", "success")
            return redirect(url_for("shippers.index"))
        except (DatabaseError, ValueError) as err:
            flash(getattr(err, "message", str(err)), "danger")

    rows = []
    admins = []
    try:
        rows = service.list_shippers(**filters)
    except DatabaseError as err:
        flash(err.message, "info")
    try:
        admins = service.list_admins()
    except DatabaseError as err:
        flash(err.message, "info")

    return render_template(
        "shippers/list.html",
        rows=rows,
        admins=admins,
        filters=filters,
        form_data=form_data,
        sort_options=service.SORT_OPTIONS,
    )


@bp.post("/shippers/<int:user_id>/update")
def update(user_id: int):
    try:
        service.update_shipper(user_id, request.form)
        flash(f"Shipper {user_id} was updated successfully.", "success")
    except (DatabaseError, ValueError) as err:
        flash(getattr(err, "message", str(err)), "danger")
    return redirect(_list_url())


@bp.post("/shippers/<int:user_id>/delete")
def delete(user_id: int):
    try:
        action = service.delete_shipper(user_id)
        if action == "deleted":
            flash(f"Shipper {user_id} was permanently deleted because no history was found.", "success")
        else:
            flash(f"Shipper {user_id} was deactivated. Historical records were preserved.", "success")
    except (DatabaseError, ValueError) as err:
        flash(getattr(err, "message", str(err)), "danger")
    return redirect(_list_url())
