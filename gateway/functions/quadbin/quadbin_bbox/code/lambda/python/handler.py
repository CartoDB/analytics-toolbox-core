"""
CARTO Analytics Toolbox - QUADBIN_BBOX
Lambda handler for Redshift external function

Returns the bounding box of a quadbin.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import cell_to_bounding_box
import json


@redshift_handler
def process_quadbin_bbox_row(row):
    """
    Get bounding box of a quadbin.

    Args:
        row: List containing [quadbin] where:
            - quadbin: Quadbin value (BIGINT)

    Returns:
        JSON string with bounding box [west, south, east, north]
    """
    if not row or len(row) < 1:
        return None

    quadbin = row[0]

    if quadbin is None:
        return None

    return json.dumps(cell_to_bounding_box(quadbin))


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_bbox_row
