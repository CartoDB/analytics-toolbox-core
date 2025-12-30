# Copyright (C) 2021 CARTO
"""
Lambda handler for VORONOIGENERIC function
"""

from carto.lambda_wrapper import redshift_handler
from lib import voronoigeneric


@redshift_handler()
def lambda_handler(row):
    """
    AWS Lambda handler for Voronoi diagram generation.

    Processes single row from Redshift external function.
    """
    if not row or len(row) < 3:
        return None
    points, bbox, voronoi_type = row[0], row[1], row[2]
    return voronoigeneric(points, bbox, voronoi_type)
