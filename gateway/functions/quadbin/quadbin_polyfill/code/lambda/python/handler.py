"""
CARTO Analytics Toolbox - QUADBIN_POLYFILL
Lambda handler for Redshift external function

Returns an array of quadbins covering a geometry at a given resolution.
"""

from carto.lambda_wrapper import redshift_handler
from quadbin import geometry_to_cells
import json


@redshift_handler
def process_quadbin_polyfill_row(row):
    """
    Fill a geometry with quadbins.

    Args:
        row: List containing [geojson, resolution] where:
            - geojson: GeoJSON string (VARCHAR)
            - resolution: Zoom level 0-26 (INT)

    Returns:
        JSON array of quadbins
    """
    if not row or len(row) < 2:
        return None

    geojson = row[0]
    resolution = row[1]

    if geojson is None or resolution is None:
        return None

    if resolution < 0 or resolution > 26:
        raise Exception("Invalid resolution, should be between 0 and 26")

    quadbins = geometry_to_cells(geojson, resolution)

    return json.dumps(quadbins)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_polyfill_row
