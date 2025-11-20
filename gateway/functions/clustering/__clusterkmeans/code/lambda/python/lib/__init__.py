# Copyright (c) 2020, Avi Arora (Python implementation)
# (https://analyticsarora.com/k-means-for-beginners-how-to-build-from-scratch-in-python/)
# Copyright (c) 2021, CARTO (lint, minor fixes)
"""
CLUSTERKMEANS function implementation using shared clustering utilities.

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
    extract_coords_from_geojson,
)


def clusterkmeans(geom_json, k):
    """
    Perform K-means clustering on MultiPoint geometry.

    Args:
        geom_json: GeoJSON MultiPoint geometry string
        k: number of clusters

    Returns:
        GeoJSON array string with cluster assignments:
        [{"cluster": id, "geom": {"coordinates": [...], "type": "Point"}}, ...]
    """
    # Parse geometry
    geom = load_geom(geom_json)

    # Validate it's a MultiPoint
    if geom.get("type") != "MultiPoint":
        raise ValueError(
            "Invalid operation: Input points parameter must be MultiPoint."
        )

    # Extract coordinates and ensure float type
    coords_list = extract_coords_from_geojson(geom)
    coords = reorder_coords(np.array(coords_list, dtype=np.float64))

    # k cannot be greater than the number of distinct coordinates
    k = min(k, count_distinct_coords(coords))

    # Run K-means
    cluster_idxs, centers, loss = KMeans()(coords, k)

    # Return cluster assignments with geometries
    result = []
    for idx, point in enumerate(coords):
        result.append(
            {
                "cluster": int(cluster_idxs[idx]),
                "geom": {"type": "Point", "coordinates": point.tolist()},
            }
        )

    return json.dumps(result)


__all__ = ["clusterkmeans", "KMeans", "PRECISION"]
