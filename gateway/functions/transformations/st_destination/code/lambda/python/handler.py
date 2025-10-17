"""
CARTO Analytics Toolbox - ST_DESTINATION
Lambda handler for Redshift external function

Calculates a destination point given distance, bearing, and units from an origin point.
"""

from carto.lambda_wrapper import redshift_handler
from lib import destination
from lib import parse_geojson_with_precision, wkt_from_geojson


@redshift_handler
def process_st_destination_row(row):
    """
    Calculate a destination point given distance, bearing, and units.

    Args:
        row: List containing [geom_geojson, distance, bearing, units] where:
            - geom_geojson: GeoJSON Point string (from ST_ASGEOJSON)
            - distance: Distance to travel
            - bearing: Bearing angle in degrees
            - units: Distance units (optional, default 'kilometers')

    Returns:
        WKT Point string representing the destination
    """
    if not row or len(row) < 3:
        return None

    geom = row[0]
    distance_str = row[1]
    bearing_str = row[2]

    # Check for required NULL parameters
    if geom is None or distance_str is None or bearing_str is None:
        return None

    # Convert VARCHAR to float - preserves precision
    distance = float(distance_str)
    bearing = float(bearing_str)

    # Handle units parameter: use default if not provided,
    # but return None if explicitly NULL
    if len(row) > 3:
        units = row[3]
        if units is None:
            return None
    else:
        units = "kilometers"

    # Parse GeoJSON with precision (matches clouds implementation)
    geojson_geom = parse_geojson_with_precision(geom)

    # Calculate destination
    result = destination(geojson_geom, distance, bearing, str(units))

    # Convert result to WKT
    geojson_str = str(result)
    return wkt_from_geojson(geojson_str)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_st_destination_row
