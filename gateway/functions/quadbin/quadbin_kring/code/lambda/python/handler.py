"""
CARTO Analytics Toolbox - QUADBIN_KRING
Lambda handler for Redshift external function

Returns a k-ring around a given quadbin.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import k_ring
import json


@redshift_handler
def process_quadbin_kring_row(row):
    """
    Get k-ring around a quadbin.

    Args:
        row: List containing [origin, size] where:
            - origin: Origin quadbin (BIGINT)
            - size: Ring size (INT)

    Returns:
        JSON array of quadbins
    """
    if not row or len(row) < 2:
        raise Exception("Invalid input")

    origin = row[0]
    size = row[1]

    if origin is None or origin <= 0:
        raise Exception("Invalid input origin")

    if size is None or size < 0:
        raise Exception("Invalid input size")

    return json.dumps(k_ring(origin, size))


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_kring_row
