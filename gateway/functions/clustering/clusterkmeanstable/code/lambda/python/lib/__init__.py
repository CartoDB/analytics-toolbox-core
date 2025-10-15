# Copyright (c) 2020, Avi Arora (Python implementation)
# (https://analyticsarora.com/k-means-for-beginners-how-to-build-from-scratch-in-python/)
# Copyright (c) 2021, CARTO (lint, minor fixes)
"""
CLUSTERKMEANSTABLE function implementation using shared clustering utilities.

This module imports shared clustering utilities from either:
- lib/clustering/ (in deployed Lambda packages - copied by packager)
- _shared/python/clustering/ (during local testing)
"""

import json
import numpy as np

try:
    # Try importing from lib/clustering (deployed package)
    from lib.clustering import KMeans
    from lib.clustering.helper import (
        load_geom,
        reorder_coords,
        count_distinct_coords,
        PRECISION,
    )
except ImportError:
    # Fall back to shared library (local testing)
    from clustering import KMeans
    from clustering.helper import (
        load_geom,
        reorder_coords,
        count_distinct_coords,
        PRECISION,
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
