"""
CARTO Analytics Toolbox - QUADBIN_TOQUADKEY
Lambda handler for Redshift external function

Converts a quadbin to a quadkey string.
"""

from carto.lambda_wrapper import redshift_handler
import numpy as np


@redshift_handler
def process_quadbin_toquadkey_row(row):
    """
    Convert quadbin to quadkey.

    Args:
        row: List containing [quadbin] where:
            - quadbin: Quadbin value (BIGINT)

    Returns:
        Quadkey string (VARCHAR)
    """
    if not row or len(row) < 1:
        return None

    quadbin = row[0]

    if quadbin is None:
        return None

    q = quadbin
    z = (q >> 52) & (0x1F)
    xy = (q & 0xFFFFFFFFFFFFF) >> (52 - z * 2)
    return np.base_repr(xy, 4).zfill(z) if z != 0 else ""


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_toquadkey_row
