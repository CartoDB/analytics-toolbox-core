"""
CARTO Analytics Toolbox - QUADBIN_TOCHILDREN
Lambda handler for Redshift external function

Returns the children of a quadbin at a given resolution.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import cell_to_children
import json


@redshift_handler
def process_quadbin_tochildren_row(row):
    """
    Get children of a quadbin.

    Args:
        row: List containing [quadbin, resolution] where:
            - quadbin: Quadbin value (BIGINT)
            - resolution: Target resolution (INT)

    Returns:
        JSON array of quadbin children
    """
    if not row or len(row) < 2:
        raise Exception("NULL argument passed to UDF")

    quadbin = row[0]
    resolution = row[1]

    if quadbin is None or resolution is None:
        raise Exception("NULL argument passed to UDF")

    return json.dumps(cell_to_children(quadbin, resolution))


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_tochildren_row
