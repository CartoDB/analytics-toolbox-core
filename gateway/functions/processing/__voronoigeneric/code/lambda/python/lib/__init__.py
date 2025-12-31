# Copyright (C) 2021 CARTO
"""
VORONOIGENERIC function implementation using shared processing utilities.

This module imports shared utilities from lib/
"""

import json
import geojson

from lib.processing import voronoi_generic, PRECISION


def voronoigeneric(points, bbox, voronoi_type):
    """
    Generate Voronoi diagram from MultiPoint geometry.

    Args:
        points: GeoJSON MultiPoint geometry string
        bbox: Bounding box array [minx, miny, maxx, maxy] as JSON string or None
        voronoi_type: Type of output ('lines' or 'poly')

    Returns:
        GeoJSON MultiLineString (lines) or MultiPolygon (poly) string or None
    """
    bbox_array = []
    if bbox is not None:
        bbox_array = json.loads(bbox)

    if points is None:
        return None

    if voronoi_type != "lines" and voronoi_type != "poly":
        return None

    if bbox is not None and len(bbox_array) != 4:
        return None

    # Parse geometry with precision
    _geom = json.loads(points)
    _geom["precision"] = PRECISION
    geom_geojson = json.dumps(_geom)
    geom_geojson = geojson.loads(geom_geojson)

    return str(voronoi_generic(geom_geojson, bbox_array, voronoi_type))


__all__ = ["voronoigeneric", "voronoi_generic", "PRECISION"]
