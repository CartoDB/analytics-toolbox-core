# Copyright (C) 2021 CARTO
"""
CARTO Analytics Toolbox - GENERATEPOINTS
Lambda handler for Redshift external function

This function generates random points within a polygon.
Returns GeoJSON Point (if npoints=1) or MultiPoint (if npoints>1).
"""

# Import lambda wrapper
from carto_analytics_toolbox_core.lambda_wrapper import redshift_handler

# Import generatepoints implementation
from lib.random import generatepoints


@redshift_handler
def process_generatepoints_row(row):
    """
    Process a single generatepoints request row.

    Args:
        row: List containing [geometry_json, npoints] where:
            - geometry_json: GeoJSON Polygon geometry string
            - npoints: number of random points to generate

    Returns:
        GeoJSON string with generated points, or None for invalid inputs
    """
    # Handle invalid row structure
    if row is None or len(row) < 2:
        return None

    geom, npoints = row[0], row[1]

    # Handle null inputs
    if geom is None or npoints is None:
        return None

    # Generate points
    result_json = generatepoints(str(geom), int(npoints))
    return result_json


# Export as lambda_handler for AWS Lambda
lambda_handler = process_generatepoints_row
