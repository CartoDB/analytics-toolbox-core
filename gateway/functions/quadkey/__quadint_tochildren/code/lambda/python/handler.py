"""
CARTO Analytics Toolbox - QUADINT_TOCHILDREN
Lambda handler for Redshift external function

Returns all children quadints at the specified resolution.
"""

from carto.lambda_wrapper import redshift_handler
from lib import zxy_from_quadint, quadint_from_zxy
import json


@redshift_handler
def process_quadint_tochildren_row(row):
    """
    Get all children quadints at the specified resolution.

    Args:
        row: List containing [quadint, resolution] where:
            - quadint: Quadint value (BIGINT)
            - resolution: Target resolution (INT), must be greater than
              current resolution

    Returns:
        JSON string representing list of children quadint values
    """
    if not row or len(row) < 2:
        raise Exception("NULL argument passed to UDF")

    quadint = row[0]
    resolution = row[1]

    if quadint is None or resolution is None:
        raise Exception("NULL argument passed to UDF")

    zxy = zxy_from_quadint(quadint)
    if zxy["z"] < 0 or zxy["z"] > 28:
        raise Exception("Wrong quadint zoom")

    if resolution < 0 or resolution <= zxy["z"]:
        raise Exception("Wrong resolution")

    diff_z = resolution - zxy["z"]
    mask = (1 << diff_z) - 1
    min_tile_x = zxy["x"] << diff_z
    max_tile_x = min_tile_x | mask
    min_tile_y = zxy["y"] << diff_z
    max_tile_y = min_tile_y | mask
    children = []
    for x in range(min_tile_x, max_tile_x + 1):
        for y in range(min_tile_y, max_tile_y + 1):
            children.append(quadint_from_zxy(resolution, x, y))
    return json.dumps(children)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadint_tochildren_row
