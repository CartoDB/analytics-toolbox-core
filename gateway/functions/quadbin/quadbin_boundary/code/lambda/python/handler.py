"""
CARTO Analytics Toolbox - QUADBIN_BOUNDARY
Lambda handler for Redshift external function

Returns the boundary of a quadbin as a WKT polygon.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import cell_to_bounding_box


@redshift_handler
def process_quadbin_boundary_row(row):
    """
    Get boundary polygon of a quadbin.

    Args:
        row: List containing [quadbin] where:
            - quadbin: Quadbin value (BIGINT)

    Returns:
        WKT polygon string
    """
    if not row or len(row) < 1:
        return None

    quadbin = row[0]

    if quadbin is None:
        return None

    bbox = cell_to_bounding_box(quadbin)
    polygon = (
        "POLYGON(({west} {south},{west} {north},"
        "{east} {north},{east} {south},{west} {south}))"
    )
    return polygon.format(west=bbox[0], south=bbox[1], east=bbox[2], north=bbox[3])


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_boundary_row
