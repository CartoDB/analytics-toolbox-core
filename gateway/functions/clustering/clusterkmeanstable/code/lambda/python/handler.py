# Copyright (c) 2020, Avi Arora (Python implementation)
# (https://analyticsarora.com/k-means-for-beginners-how-to-build-from-scratch-in-python/)
# Copyright (c) 2021, CARTO (lint, minor fixes)
# Copyright (c) 2025, CARTO (Lambda adaptation)

"""
CARTO Analytics Toolbox - CLUSTERKMEANSTABLE
Lambda handler for Redshift external function

This function performs K-means clustering on coordinates from a table geometry format.
Returns JSON array with cluster assignments and indices.
"""

# Import lambda wrapper
from carto.lambda_wrapper import redshift_handler

# Import clustering implementation
from lib import clusterkmeanstable


@redshift_handler
def process_clusterkmeanstable_row(row):
    """
    Process a single clustering request row for table geometry format.

    Args:
        row: List containing [geometry_json, k] where:
            - geometry_json: JSON string with _coords array (flat list of x,y pairs)
            - k: number of clusters

    Returns:
        JSON string with cluster assignments and indices, or None for invalid inputs
    """
    # Handle invalid row structure
    if row is None or len(row) < 2:
        return None

    geom, k = row[0], row[1]

    # Handle null inputs
    if geom is None or k is None:
        return None

    # Process the clustering
    result_json = clusterkmeanstable(str(geom), int(k))
    return result_json


# Export as lambda_handler for AWS Lambda
lambda_handler = process_clusterkmeanstable_row
