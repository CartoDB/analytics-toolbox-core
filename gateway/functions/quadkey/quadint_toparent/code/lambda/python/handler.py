"""
CARTO Analytics Toolbox - QUADINT_TOPARENT
Lambda handler for Redshift external function

Returns the parent quadint at the specified resolution.
"""

from carto.lambda_wrapper import redshift_handler
from lib import zxy_from_quadint, quadint_from_zxy


@redshift_handler
def process_quadint_toparent_row(row):
    """
    Get the parent quadint at the specified resolution.

    Args:
        row: List containing [quadint, resolution] where:
            - quadint: Quadint value (BIGINT)
            - resolution: Target resolution (INT), must be less than current resolution

    Returns:
        Parent quadint value (BIGINT)
    """
    if not row or len(row) < 2:
        raise Exception("NULL argument passed to UDF")

    quadint = row[0]
    resolution = row[1]

    if quadint is None or resolution is None:
        raise Exception("NULL argument passed to UDF")

    zxy = zxy_from_quadint(quadint)
    if zxy["z"] < 1 or zxy["z"] > 29:
        raise Exception("Wrong quadint zoom")

    if resolution < 0 or resolution >= zxy["z"]:
        raise Exception("Wrong resolution")

    return quadint_from_zxy(
        resolution,
        zxy["x"] >> (zxy["z"] - resolution),
        zxy["y"] >> (zxy["z"] - resolution),
    )


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadint_toparent_row
