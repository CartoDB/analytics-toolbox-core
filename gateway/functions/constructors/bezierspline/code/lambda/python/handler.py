# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO
# Copyright (c) 2025, CARTO (Lambda adaptation)

"""
CARTO Analytics Toolbox - ST_BEZIERSPLINE
Lambda handler for Redshift external function

This function takes a LineString and returns a curved version by applying
a Bezier spline algorithm.
"""

# Import lambda wrapper
from carto_analytics_toolbox_core.lambda_wrapper import redshift_handler

# Import bezier spline implementation
from lib import bezier_spline


@redshift_handler
def process_bezierspline_row(row):
    """
    Process a single ST_BEZIERSPLINE request row.

    Args:
        row: List containing [linestring_json, resolution, sharpness] where:
            - linestring_json: GeoJSON LineString geometry string
            - resolution: Optional resolution (default 10000)
            - sharpness: Optional sharpness (default 0.85)

    Returns:
        GeoJSON LineString string with bezier spline applied, or None for
        invalid inputs
    """
    # Handle invalid row structure
    if row is None or len(row) < 1:
        return None

    linestring = row[0]

    # Handle null linestring
    if linestring is None:
        return None

    # Get resolution parameter (with default for missing, None for NULL)
    if len(row) > 1:
        resolution = row[1]
        if resolution is None:
            return None  # NULL resolution -> NULL result
    else:
        resolution = 10000  # Missing parameter -> default

    # Get sharpness parameter (with default for missing, None for NULL)
    if len(row) > 2:
        sharpness = row[2]
        if sharpness is None:
            return None  # NULL sharpness -> NULL result
    else:
        sharpness = 0.85  # Missing parameter -> default

    # Process the bezier spline
    result_json = bezier_spline(str(linestring), int(resolution), float(sharpness))
    return result_json


# Export as lambda_handler for AWS Lambda
lambda_handler = process_bezierspline_row
