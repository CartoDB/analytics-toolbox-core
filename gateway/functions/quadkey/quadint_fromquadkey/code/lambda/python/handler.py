"""
CARTO Analytics Toolbox - QUADINT_FROMQUADKEY
Lambda handler for Redshift external function

Converts a quadkey string to a quadint.
"""

from carto.lambda_wrapper import redshift_handler
from lib import quadint_from_zxy
import mercantile


@redshift_handler
def process_quadint_fromquadkey_row(row):
    """
    Convert quadkey to quadint.

    Args:
        row: List containing [quadkey] where:
            - quadkey: Quadkey string (VARCHAR)

    Returns:
        Quadint value (BIGINT)
    """
    if not row or len(row) < 1:
        raise Exception("NULL argument passed to UDF")

    quadkey = row[0]

    if quadkey is None:
        raise Exception("NULL argument passed to UDF")

    # Empty string is a valid quadkey (represents z=0, x=0, y=0)
    tile = mercantile.quadkey_to_tile(quadkey)
    return quadint_from_zxy(tile.z, tile.x, tile.y)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadint_fromquadkey_row
