"""
CARTO Analytics Toolbox - QUADINT_KRING
Lambda handler for Redshift external function

Returns all quadints within a square ring of the specified size around the origin.
"""

from carto.lambda_wrapper import redshift_handler
from lib import sibling
import json


@redshift_handler
def process_quadint_kring_row(row):
    """
    Get all quadints within a k-ring around the origin.

    Args:
        row: List containing [origin, size] where:
            - origin: Origin quadint value (BIGINT)
            - size: Ring size (INT), must be >= 0

    Returns:
        JSON string representing list of quadint values in the k-ring
    """
    if not row or len(row) < 2:
        raise Exception("Invalid input")

    origin = row[0]
    size = row[1]

    if origin is None or origin <= 0:
        raise Exception("Invalid input origin")

    if size is None or size < 0:
        raise Exception("Invalid input size")

    corner_quadint = origin
    # Traverse to top left corner
    for i in range(0, size):
        corner_quadint = sibling(corner_quadint, "left")
        corner_quadint = sibling(corner_quadint, "up")

    neighbors = []
    traversal_quadint = 0

    for j in range(0, size * 2 + 1):
        traversal_quadint = corner_quadint
        for i in range(0, size * 2 + 1):
            neighbors.append(traversal_quadint)
            traversal_quadint = sibling(traversal_quadint, "right")
        corner_quadint = sibling(corner_quadint, "down")

    return json.dumps(neighbors)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadint_kring_row
