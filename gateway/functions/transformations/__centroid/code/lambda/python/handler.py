"""
CARTO Analytics Toolbox - ST_CENTROID
Lambda handler for Redshift external function

Calculates the centroid of a geometry.
"""

from carto.lambda_wrapper import redshift_handler
from lib import centroid
from lib import parse_geojson_with_precision, wkt_from_geojson


@redshift_handler
def process_st_centroid_row(row):
    """
    Calculate the centroid of a geometry.

    Args:
        row: List containing [geom_geojson] where:
            - geom_geojson: GeoJSON string (from ST_ASGEOJSON)

    Returns:
        WKT Point string representing the centroid
    """
    if not row or len(row) < 1:
        return None

    geom = row[0]

    if geom is None:
        return None

    # Parse GeoJSON with precision (matches clouds implementation)
    geojson_geom = parse_geojson_with_precision(geom)

    # Calculate centroid
    result = centroid(geojson_geom)

    # Convert result to WKT
    geojson_str = str(result)
    return wkt_from_geojson(geojson_str)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_st_centroid_row
