"""
CARTO Analytics Toolbox - QUADINT_SIBLING
Lambda handler for Redshift external function

Returns the sibling quadint in the specified direction.
"""

from carto.lambda_wrapper import redshift_handler
from lib import sibling


@redshift_handler
def process_quadint_sibling_row(row):
    """
    Get the sibling quadint in the specified direction.

    Args:
        row: List containing [quadint, direction] where:
            - quadint: Quadint value (BIGINT)
            - direction: Direction string - 'left', 'right', 'up', or 'down' (VARCHAR)

    Returns:
        Sibling quadint value (BIGINT)
    """
    if not row or len(row) < 2:
        raise Exception("NULL argument passed to UDF")

    quadint = row[0]
    direction = row[1]

    if quadint is None or direction is None:
        raise Exception("NULL argument passed to UDF")

    return sibling(quadint, direction)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadint_sibling_row
