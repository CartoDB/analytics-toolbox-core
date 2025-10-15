# Copyright (C) 2021 CARTO
"""
Lambda handler for DELAUNAYGENERIC function
"""

from carto_analytics_toolbox_core.lambda_wrapper import redshift_handler
from lib import delaunaygeneric


@redshift_handler()
def lambda_handler(row):
    """
    AWS Lambda handler for Delaunay triangulation.

    Processes single row from Redshift external function.
    """
    if not row or len(row) < 2:
        return None
    points, delaunay_type = row[0], row[1]
    return delaunaygeneric(points, delaunay_type)
