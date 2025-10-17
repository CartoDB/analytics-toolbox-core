"""
CARTO Analytics Toolbox - QUADINT_POLYFILL
Lambda handler for Redshift external function

Converts a GeoJSON geometry into a set of quadints at the specified resolution.
"""

from carto.lambda_wrapper import redshift_handler
from lib import quadint_from_zxy, tilecover
import json


@redshift_handler
def process_quadint_polyfill_row(row):
    """
    Get quadints that cover a GeoJSON geometry.

    Args:
        row: List containing [geojson, resolution] where:
            - geojson: GeoJSON geometry string (VARCHAR(MAX))
            - resolution: Zoom level (INT)

    Returns:
        JSON string representing list of quadint values covering the geometry
    """
    if not row or len(row) < 2:
        raise Exception("NULL argument passed to UDF")

    geojson = row[0]
    resolution = row[1]

    if geojson is None or resolution is None:
        raise Exception("NULL argument passed to UDF")

    pol = json.loads(geojson)
    quadints = []
    if pol["type"] == "GeometryCollection":
        for geom in pol["geometries"]:
            quadints += [
                quadint_from_zxy(int(tile[2]), int(tile[0]), int(tile[1]))
                for tile in tilecover.get_tiles(
                    geom, {"min_zoom": resolution, "max_zoom": resolution}
                )
            ]
        quadints = list(set(quadints))
    else:
        quadints = [
            quadint_from_zxy(int(tile[2]), int(tile[0]), int(tile[1]))
            for tile in tilecover.get_tiles(
                pol, {"min_zoom": resolution, "max_zoom": resolution}
            )
        ]

    return json.dumps(quadints)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadint_polyfill_row
