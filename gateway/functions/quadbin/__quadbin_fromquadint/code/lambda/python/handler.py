"""
CARTO Analytics Toolbox - __QUADBIN_FROMQUADINT
Lambda handler for Redshift external function

Internal function to convert a quadint to a quadbin.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import tile_to_cell


@redshift_handler
def process_quadbin_fromquadint_row(row):
    """
    Convert quadint to quadbin.

    Args:
        row: List containing [quadint] where:
            - quadint: Quadint value (BIGINT)

    Returns:
        Quadbin value (BIGINT)
    """
    if not row or len(row) < 1:
        return None

    quadint = row[0]

    if quadint is None:
        return None

    z = quadint & 31
    x = (quadint >> 5) & ((1 << z) - 1)
    y = quadint >> (z + 5)

    return tile_to_cell((x, y, z))


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_fromquadint_row
