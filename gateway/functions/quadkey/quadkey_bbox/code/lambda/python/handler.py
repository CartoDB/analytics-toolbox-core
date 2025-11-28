"""
CARTO Analytics Toolbox - QUADKEY_BBOX (internal helper for __QUADKEY_BBOX)
Lambda handler for Redshift external function

Returns the bounding box of a quadkey string as [west, south, east, north].
"""

from carto.lambda_wrapper import redshift_handler
import mercantile
import json


@redshift_handler
def process_quadkey_bbox_row(row):
    """
    Get the bounding box of a quadkey string.

    Args:
        row: List containing [quadkey] where:
            - quadkey: Quadkey string (VARCHAR(MAX))

    Returns:
        JSON string representing array [west, south, east, north]
    """
    if not row or len(row) < 1:
        raise Exception("NULL argument passed to UDF")

    quadkey = row[0]

    if quadkey is None:
        raise Exception("NULL argument passed to UDF")

    tile = mercantile.quadkey_to_tile(quadkey)
    bounds = mercantile.bounds(tile.x, tile.y, tile.z)
    return json.dumps([bounds.west, bounds.south, bounds.east, bounds.north])


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadkey_bbox_row
