"""
CARTO Analytics Toolbox - QUADINT_BOUNDARY
Lambda handler for Redshift external function

Returns the boundary of a quadint as GeoJSON geometry.
"""

from carto.lambda_wrapper import redshift_handler
from lib import zxy_from_quadint
import mercantile
import json


@redshift_handler
def process_quadint_boundary_row(row):
    """
    Get the boundary geometry of a quadint.

    Args:
        row: List containing [quadint] where:
            - quadint: Quadint value (BIGINT)

    Returns:
        GeoJSON geometry string
    """
    if not row or len(row) < 1:
        raise Exception("NULL argument passed to UDF")

    quadint = row[0]

    if quadint is None:
        raise Exception("NULL argument passed to UDF")

    tile = zxy_from_quadint(quadint)
    geojson = mercantile.feature(mercantile.Tile(tile["x"], tile["y"], tile["z"]))
    return json.dumps(geojson["geometry"])


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadint_boundary_row
