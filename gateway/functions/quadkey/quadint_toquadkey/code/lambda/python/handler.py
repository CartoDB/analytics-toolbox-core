"""
CARTO Analytics Toolbox - QUADINT_TOQUADKEY
Lambda handler for Redshift external function

Converts a quadint to a quadkey string.
"""

from carto.lambda_wrapper import redshift_handler
from lib import zxy_from_quadint
import mercantile


@redshift_handler
def process_quadint_toquadkey_row(row):
    """
    Convert quadint to quadkey.

    Args:
        row: List containing [quadint] where:
            - quadint: Quadint value (BIGINT)

    Returns:
        Quadkey string (VARCHAR)
    """
    if not row or len(row) < 1:
        raise Exception("NULL argument passed to UDF")

    quadint = row[0]

    if quadint is None:
        raise Exception("NULL argument passed to UDF")

    tile = zxy_from_quadint(quadint)
    return mercantile.quadkey(tile["x"], tile["y"], tile["z"])


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadint_toquadkey_row
