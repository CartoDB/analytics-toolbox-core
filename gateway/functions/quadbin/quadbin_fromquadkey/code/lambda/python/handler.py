"""
CARTO Analytics Toolbox - QUADBIN_FROMQUADKEY
Lambda handler for Redshift external function

Converts a quadkey string to a quadbin.
"""

from carto.lambda_wrapper import redshift_handler


@redshift_handler
def process_quadbin_fromquadkey_row(row):
    """
    Convert quadkey to quadbin.

    Args:
        row: List containing [quadkey] where:
            - quadkey: Quadkey string (VARCHAR)

    Returns:
        Quadbin value (BIGINT)
    """
    if not row or len(row) < 1:
        return None

    quadkey = row[0]

    if quadkey is None:
        quadkey = ""

    z = len(quadkey)
    xy = int(quadkey or "0", 4)
    return (
        0x4000000000000000
        | (1 << 59)
        | (z << 52)
        | (xy << (52 - z * 2))
        | (0xFFFFFFFFFFFFF >> (z * 2))
    )


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_fromquadkey_row
