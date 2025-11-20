# Copyright (c) 2020, Avi Arora (Python implementation)
# (https://analyticsarora.com/k-means-for-beginners-how-to-build-from-scratch-in-python/)
# Copyright (c) 2021, CARTO (lint, minor fixes)
"""
CLUSTERKMEANSTABLE function implementation using shared clustering utilities.

This module imports shared clustering utilities from lib/clustering/
which is populated during the build step from functions/_shared/python/clustering/
"""

import json
import numpy as np

# Import from lib/clustering (copied during build/deploy)
from lib.clustering import (
    KMeans,
    PRECISION,
    load_geom,
    reorder_coords,
    count_distinct_coords,
)


def clusterkmeanstable(geom_json, k):
    """
    Perform K-means clustering on table geometry coordinates.

    Args:
        geom_json: JSON string with _coords array (flat list of x,y pairs)
        k: number of clusters

    Returns:
        JSON string with cluster assignments: [{"c": cluster_id, "i": index}, ...]
    """
    # Parse geometry
    geom = load_geom(geom_json)
    points = geom["_coords"]

    # Convert flat coordinate array to Nx2 array
    coords = reorder_coords(
        np.array([[points[i], points[i + 1]] for i in range(0, len(points) - 1, 2)])
    )

    # k cannot be greater than the number of distinct coordinates
    k = min(k, count_distinct_coords(coords))

    # Run K-means
    cluster_idxs, centers, loss = KMeans()(coords, k)

    # Return cluster assignments with 1-based indices
    return json.dumps(
        [
            {"c": int(cluster_idxs[idx]), "i": idx + 1}
            for idx, point in enumerate(coords)
        ]
    )


__all__ = ["clusterkmeanstable", "KMeans", "PRECISION"]
