"""
CARTO Analytics Toolbox - ST_GREATCIRCLE
Lambda handler for Redshift external function

Calculates a great circle line between two points.
"""

from carto.lambda_wrapper import redshift_handler
from lib import great_circle
from lib import parse_geojson_with_precision, wkt_from_geojson


@redshift_handler
def process_st_greatcircle_row(row):
    """
    Calculate a great circle line between two points.

    Args:
        row: List containing [start_point_geojson, end_point_geojson, n_points] where:
            - start_point_geojson: GeoJSON Point string (from ST_ASGEOJSON)
            - end_point_geojson: GeoJSON Point string (from ST_ASGEOJSON)
            - n_points: Number of points to generate (optional, default 100)

    Returns:
        WKT LineString representing the great circle
    """
    if not row or len(row) < 2:
        return None

    start_point = row[0]
    end_point = row[1]

    # Check for required NULL parameters
    if start_point is None or end_point is None or start_point == end_point:
        return None

    # Handle n_points parameter: use default if not provided,
    # but return None if explicitly NULL
    if len(row) > 2:
        n_points = row[2]
        if n_points is None:
            return None
    else:
        n_points = 100

    # Parse GeoJSON with precision (matches clouds implementation)
    start_geojson = parse_geojson_with_precision(start_point)
    end_geojson = parse_geojson_with_precision(end_point)

    # Calculate great circle
    result = great_circle(start_geojson, end_geojson, int(n_points))

    # Convert result to WKT
    geojson_str = str(result)
    return wkt_from_geojson(geojson_str)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_st_greatcircle_row
