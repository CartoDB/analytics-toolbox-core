"""
CARTO Analytics Toolbox - QUADBIN_ISVALID
Lambda handler for Redshift external function

Checks if a quadbin is valid.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import is_valid_cell


@redshift_handler
def process_quadbin_isvalid_row(row):
    """
    Check if quadbin is valid.

    Args:
        row: List containing [quadbin] where:
            - quadbin: Quadbin value (BIGINT)

    Returns:
        Boolean value
    """
    if not row or len(row) < 1:
        return False

    quadbin = row[0]

    if quadbin is None:
        return False

    return is_valid_cell(quadbin)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_isvalid_row
