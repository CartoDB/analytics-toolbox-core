"""
CARTO Analytics Toolbox - QUADBIN_FROMZXY
Lambda handler for Redshift external function

Converts tile coordinates (z, x, y) to a quadbin.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import tile_to_cell


@redshift_handler
def process_quadbin_fromzxy_row(row):
    """
    Convert tile coordinates to quadbin.

    Args:
        row: List containing [z, x, y] where:
            - z: Zoom level (BIGINT)
            - x: Tile X coordinate (BIGINT)
            - y: Tile Y coordinate (BIGINT)

    Returns:
        Quadbin value (BIGINT)
    """
    if not row or len(row) < 3:
        raise Exception("NULL argument passed to UDF")

    z = row[0]
    x = row[1]
    y = row[2]

    if z is None or x is None or y is None:
        raise Exception("NULL argument passed to UDF")

    return tile_to_cell((x, y, z))


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_fromzxy_row
