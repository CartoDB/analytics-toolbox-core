# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO
# Copyright (c) 2025, CARTO (Lambda adaptation)

"""
CARTO Analytics Toolbox - ST_MAKEELLIPSE
Lambda handler for Redshift external function

This function creates an elliptical Polygon with specified parameters.
"""

# Import lambda wrapper
from carto_analytics_toolbox_core.lambda_wrapper import redshift_handler

# Import ellipse implementation
from lib import ellipse


@redshift_handler
def process_makeellipse_row(row):
    """
    Process a single ST_MAKEELLIPSE request row.

    Args:
        row: List containing [center, xSemiAxis, ySemiAxis, angle, units, steps]
            - center: GeoJSON Point geometry string
            - xSemiAxis: Semi-major axis length
            - ySemiAxis: Semi-minor axis length
            - angle: Optional rotation angle (default 0)
            - units: Optional units (default 'kilometers')
            - steps: Optional number of steps (default 64)

    Returns:
        GeoJSON Polygon string with ellipse geometry, or None for invalid inputs
    """
    # Handle invalid row structure
    if row is None or len(row) < 3:
        return None

    center = row[0]
    x_semi_axis = row[1]
    y_semi_axis = row[2]

    # Handle null required inputs
    if center is None or x_semi_axis is None or y_semi_axis is None:
        return None

    # Get angle parameter (with default for missing, None for NULL)
    if len(row) > 3:
        angle = row[3]
        if angle is None:
            return None  # NULL angle -> NULL result
    else:
        angle = 0  # Missing parameter -> default

    # Get units parameter (with default for missing or NULL)
    if len(row) > 4:
        units = row[4] if row[4] is not None else "kilometers"
    else:
        units = "kilometers"

    # Get steps parameter (with default for missing or NULL)
    if len(row) > 5:
        steps = row[5] if row[5] is not None else 64
    else:
        steps = 64

    # Prepare options
    geom_options = {
        "angle": float(angle),
        "units": str(units),
        "steps": int(steps),
    }

    # Process the ellipse
    result_json = ellipse(
        center=str(center),
        x_semi_axis=float(x_semi_axis),
        y_semi_axis=float(y_semi_axis),
        options=geom_options,
    )
    return result_json


# Export as lambda_handler for AWS Lambda
lambda_handler = process_makeellipse_row
