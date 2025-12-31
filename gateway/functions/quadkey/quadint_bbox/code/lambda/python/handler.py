"""
CARTO Analytics Toolbox - QUADINT_BBOX
Lambda handler for Redshift external function

Returns the bounding box of a quadint as [west, south, east, north].
"""

from carto.lambda_wrapper import redshift_handler
from lib import zxy_from_quadint
import mercantile
import json


@redshift_handler
def process_quadint_bbox_row(row):
    """
    Get the bounding box of a quadint.

    Args:
        row: List containing [quadint] where:
            - quadint: Quadint value (BIGINT)

    Returns:
        JSON string representing array [west, south, east, north]
    """
    if not row or len(row) < 1:
        raise Exception("NULL argument passed to UDF")

    quadint = row[0]

    if quadint is None:
        raise Exception("NULL argument passed to UDF")

    tile = zxy_from_quadint(quadint)
    bounds = mercantile.bounds(tile["x"], tile["y"], tile["z"])
    return json.dumps([bounds.west, bounds.south, bounds.east, bounds.north])


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadint_bbox_row
