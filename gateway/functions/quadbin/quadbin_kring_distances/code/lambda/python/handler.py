"""
CARTO Analytics Toolbox - QUADBIN_KRING_DISTANCES
Lambda handler for Redshift external function

Returns k-rings around a given quadbin with their distances.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import k_ring_distances
import json


@redshift_handler
def process_quadbin_kring_distances_row(row):
    """
    Get k-rings with distances around a quadbin.

    Args:
        row: List containing [origin, size] where:
            - origin: Origin quadbin (BIGINT)
            - size: Ring size (INT)

    Returns:
        JSON array of arrays with quadbins grouped by distance
    """
    if not row or len(row) < 2:
        raise Exception("Invalid input")

    origin = row[0]
    size = row[1]

    if origin is None or origin <= 0:
        raise Exception("Invalid input origin")

    if size is None or size < 0:
        raise Exception("Invalid input size")

    return json.dumps(k_ring_distances(origin, size))


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_kring_distances_row
