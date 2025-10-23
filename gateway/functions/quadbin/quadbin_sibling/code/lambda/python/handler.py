"""
CARTO Analytics Toolbox - QUADBIN_SIBLING
Lambda handler for Redshift external function

Returns the sibling of a quadbin in a given direction.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import cell_sibling


@redshift_handler
def process_quadbin_sibling_row(row):
    """
    Get sibling of a quadbin.

    Args:
        row: List containing [quadbin, direction] where:
            - quadbin: Quadbin value (BIGINT)
            - direction: Direction string (VARCHAR)

    Returns:
        Sibling quadbin value (BIGINT)
    """
    if not row or len(row) < 2:
        return None

    quadbin = row[0]
    direction = row[1]

    if quadbin is None or direction is None:
        return None

    return cell_sibling(quadbin, direction)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_sibling_row
