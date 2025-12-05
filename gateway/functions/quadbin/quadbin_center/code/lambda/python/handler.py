"""
CARTO Analytics Toolbox - QUADBIN_CENTER
Lambda handler for Redshift external function

Returns the center point of a quadbin as a WKT point.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import cell_to_point


@redshift_handler
def process_quadbin_center_row(row):
    """
    Get center point of a quadbin.

    Args:
        row: List containing [quadbin] where:
            - quadbin: Quadbin value (BIGINT)

    Returns:
        WKT point string
    """
    if not row or len(row) < 1:
        return None

    quadbin = row[0]

    if quadbin is None:
        return None

    (x, y) = cell_to_point(quadbin)
    return "POINT ({} {})".format(x, y)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_center_row
