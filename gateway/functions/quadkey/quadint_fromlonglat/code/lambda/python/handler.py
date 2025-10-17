"""
CARTO Analytics Toolbox - QUADINT_FROMLONGLAT
Lambda handler for Redshift external function

Converts longitude, latitude coordinates to a quadint at the specified resolution.
"""

from carto.lambda_wrapper import redshift_handler
from lib import quadint_from_zxy, clip_number
import mercantile


@redshift_handler
def process_quadint_fromlonglat_row(row):
    """
    Convert longitude, latitude to quadint.

    Args:
        row: List containing [longitude, latitude, resolution] where:
            - longitude: Longitude in degrees (FLOAT8)
            - latitude: Latitude in degrees (FLOAT8)
            - resolution: Zoom level 0-29 (INT)

    Returns:
        Quadint value (BIGINT)
    """
    if not row or len(row) < 3:
        raise Exception("NULL argument passed to UDF")

    longitude = row[0]
    latitude = row[1]
    resolution = row[2]

    if longitude is None or latitude is None or resolution is None:
        raise Exception("NULL argument passed to UDF")

    if resolution < 0 or resolution > 29:
        raise Exception("Wrong zoom")

    lat = clip_number(latitude, -85.05, 85.05)
    tile = mercantile.tile(longitude, lat, resolution)
    return quadint_from_zxy(resolution, tile.x, tile.y)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadint_fromlonglat_row
