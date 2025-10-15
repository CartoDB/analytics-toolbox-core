# Copyright (c) 2020, Avi Arora (Python implementation)
# (https://analyticsarora.com/k-means-for-beginners-how-to-build-from-scratch-in-python/)
# Copyright (c) 2021, CARTO (lint, minor fixes)
"""
CLUSTERKMEANS function implementation using shared clustering utilities.

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
        extract_coords_from_geojson,
        PRECISION,
    )
except ImportError:
    # Fall back to shared library (local testing)
    from clustering import KMeans
    from clustering.helper import (
        load_geom,
        reorder_coords,
        count_distinct_coords,
        extract_coords_from_geojson,
        PRECISION,
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
