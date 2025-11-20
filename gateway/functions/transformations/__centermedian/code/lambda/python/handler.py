"""
CARTO Analytics Toolbox - ST_CENTERMEDIAN
Lambda handler for Redshift external function

Calculates the median center (geometric median) of a geometry.
"""

from carto.lambda_wrapper import redshift_handler
from lib import center_median
from lib import parse_geojson_with_precision, wkt_from_geojson


@redshift_handler
def process_st_centermedian_row(row):
    """
    Calculate the median center of a geometry.

    Args:
        row: List containing [geom_geojson, n_iter] where:
            - geom_geojson: GeoJSON string (from ST_ASGEOJSON)
            - n_iter: Number of iterations for optimization (optional, default 100)

    Returns:
        WKT Point string representing the median center
    """
    if not row or len(row) < 1:
        return None

    geom = row[0]
    n_iter = row[1] if len(row) > 1 and row[1] is not None else 100

    if geom is None or n_iter is None:
        return None

    # Parse GeoJSON with precision (matches clouds implementation)
    geojson_geom = parse_geojson_with_precision(geom)

    # Calculate median center
    result = center_median(geojson_geom, int(n_iter))

    # Convert result to WKT
    geojson_str = str(result)
    return wkt_from_geojson(geojson_str)


# Export as lambda_handler for AWS Lambda
lambda_handler = process_st_centermedian_row
