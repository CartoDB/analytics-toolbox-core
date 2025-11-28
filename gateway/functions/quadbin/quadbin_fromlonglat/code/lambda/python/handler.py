"""
CARTO Analytics Toolbox - QUADBIN_FROMLONGLAT
Lambda handler for Redshift external function

Converts longitude, latitude coordinates to a quadbin at the specified resolution.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import point_to_cell


@redshift_handler
def process_quadbin_fromlonglat_row(row):
    """
    Convert longitude, latitude to quadbin.

    Args:
        row: List containing [longitude, latitude, resolution] where:
            - longitude: Longitude in degrees (FLOAT8)
            - latitude: Latitude in degrees (FLOAT8)
            - resolution: Zoom level 0-26 (INT)

    Returns:
        Quadbin value (BIGINT)
    """
    if not row or len(row) < 3:
        return None

    longitude_str = row[0]
    latitude_str = row[1]
    resolution = row[2]

    if longitude_str is None or latitude_str is None or resolution is None:
        return None

    if resolution < 0 or resolution > 26:
        raise Exception("Invalid resolution: should be between 0 and 26")

    # Convert VARCHAR to float - preserves full precision
    # that would be lost in FLOAT8->JSON
    longitude = float(longitude_str)
    latitude = float(latitude_str)

    # Return as string to preserve precision for large BIGINT values (> 2^53-1)
    # Redshift external functions use JavaScript JSON parsing which loses precision
    result = point_to_cell(longitude, latitude, resolution)
    return str(result)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_fromlonglat_row
