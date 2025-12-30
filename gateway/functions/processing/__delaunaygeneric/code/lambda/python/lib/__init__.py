# Copyright (C) 2021 CARTO
"""
DELAUNAYGENERIC function implementation using shared processing utilities.

This module imports shared utilities from lib/
"""

import json
import geojson
from scipy.spatial import Delaunay

from lib.processing import PRECISION


def delaunaygeneric(points, delaunay_type):
    """
    Generate Delaunay triangulation from MultiPoint geometry.

    Args:
        points: GeoJSON MultiPoint geometry string
        delaunay_type: Type of output ('lines' or 'poly')

    Returns:
        GeoJSON MultiLineString (lines) or MultiPolygon (poly) string or None
    """
    if points is None:
        return None

    if delaunay_type != "lines" and delaunay_type != "poly":
        return None

    # Parse geometry with precision
    _geom = json.loads(points)
    _geom["precision"] = PRECISION
    geom = json.dumps(_geom)
    geom = geojson.loads(geom)

    # Extract coordinates
    coords = []
    if geom.type != "MultiPoint":
        raise ValueError(
            "Invalid operation: Input points parameter must be MultiPoint."
        )
    else:
        coords = list(geojson.utils.coords(geom))

    # Perform Delaunay triangulation
    tri = Delaunay(coords)

    # Build output geometry
    lines = []
    for triangle in tri.simplices:
        p_1 = coords[triangle[0]]
        p_2 = coords[triangle[1]]
        p_3 = coords[triangle[2]]
        if delaunay_type == "lines":
            lines.append([p_1, p_2, p_3, p_1])
        else:
            lines.append([[p_1, p_2, p_3, p_1]])

    # Return appropriate geometry type
    if delaunay_type == "lines":
        return str(geojson.MultiLineString(lines, precision=PRECISION))
    else:
        return str(geojson.MultiPolygon(lines, precision=PRECISION))


__all__ = ["delaunaygeneric", "PRECISION"]
