# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

"""
Shared helper utilities for transformation functions.

Contains only truly shared utilities used by multiple functions:
- PRECISION: Standard precision for GeoJSON output
- wkt_from_geojson: Convert GeoJSON to WKT format
- parse_geojson_with_precision: Parse GeoJSON string with precision setting
- euclidean_distance: Calculate euclidean distance between two points
  (used by ST_CENTERMEDIAN, ST_CENTROID)
- coords_mean: Calculate mean of coordinates
  (used by ST_CENTERMEAN, ST_CENTROID)
- remove_end_polygon_point: Remove duplicate end point from polygon coordinates
  (used by ST_CENTERMEAN, center_mean function)
- center_mean: Calculate mean center of geometry
  (used by ST_CENTERMEAN, ST_CENTERMEDIAN)
"""

from __future__ import division
from math import sqrt
import geojson
import json

PRECISION = 15


def euclidean_distance(p1, p2):
    """Calculate euclidean distance between two 2D points."""
    return sqrt((p2[0] - p1[0]) ** 2 + (p2[1] - p1[1]) ** 2)


def coords_mean(coords_list):
    """
    Calculate the mean of a list of coordinates.

    Used by ST_CENTERMEAN and ST_CENTROID for point-based geometries.
    """
    sum_x = 0
    sum_y = 0
    total_features = 0
    for point in coords_list:
        total_features += 1
        sum_x += point[0]
        sum_y += point[1]

    if total_features == 0:
        return geojson.Point(0, 0)

    return geojson.Point(
        (sum_x / total_features, sum_y / total_features), precision=PRECISION
    )


def remove_end_polygon_point(geom):
    """
    Remove duplicate end point from polygon coordinates.

    Recursively processes polygon coordinates to remove the duplicate last point.
    Used by center_mean function.
    """
    if len(geom) == 0:
        raise Exception(
            "Invalid operation: Found empty point. Please check the input geometry"
        )
    elif type(geom[0]) is not list:
        return tuple(geom)
    elif type(geom[0][0]) is not list:
        new_list = []
        for poly_point in geom[:-1]:
            new_list.append(remove_end_polygon_point(poly_point))
        return new_list
    else:
        new_list = []
        for poly in geom:
            new_list += remove_end_polygon_point(poly)
        return new_list


def center_mean(geom):
    """
    Calculate the mean center of a geometry.

    Used by ST_CENTERMEAN and ST_CENTERMEDIAN.
    """
    # Take the type of geometry
    coords = []

    if geom.type == "GeometryCollection":
        for feature in geom.geometries:
            if feature.type == "Polygon" or feature.type == "MultiPolygon":
                coords += remove_end_polygon_point(feature.coordinates)
            else:
                coords += list(geojson.utils.coords(feature))
    elif geom.type == "Polygon" or geom.type == "MultiPolygon":
        coords = remove_end_polygon_point(geom.coordinates)
    else:
        coords = list(geojson.utils.coords(geom))

    return coords_mean(coords)


def parse_geojson_with_precision(geom_json_str):
    """
    Parse GeoJSON string and set precision.

    This matches the clouds implementation which sets precision on the
    GeoJSON before parsing to ensure consistent output precision.

    Args:
        geom_json_str: GeoJSON string to parse

    Returns:
        Parsed geojson object with precision set
    """
    if geom_json_str is None:
        return None

    _geom = json.loads(geom_json_str)
    _geom["precision"] = PRECISION
    geojson_geom = json.dumps(_geom)
    geojson_geom = geojson.loads(geojson_geom)
    return geojson_geom


def wkt_from_geojson(geom):
    def get_ring(coords):
        str_return = "("
        for p in coords:
            str_return += str(p[0]) + " " + str(p[1]) + ","
        return str_return[:-1] + ")"

    if geom is None:
        return None

    _geom = json.loads(geom)
    _geom["precision"] = PRECISION
    geom = json.dumps(_geom)

    geojson_str = geojson.loads(geom)
    geojson_type = geojson_str.type

    coords = []
    # TODO: Include multitypes

    if geojson_type == "Point":
        coords = list(geojson.utils.coords(geojson_str))
        return "POINT (" + str(coords[0][0]) + " " + str(coords[0][1]) + ")"

    elif geojson_type == "LineString":
        coords = list(geojson.utils.coords(geojson_str))
        return "LINESTRING" + get_ring(coords)

    elif geojson_type == "Polygon":
        coords = geojson_str["coordinates"]
        str_return = "POLYGON ( "
        for ring in coords:
            str_return += get_ring(ring) + ","
        return str_return[:-1] + ")"

    elif geojson_type == "MultiPoint":
        return "MULTIPOINT" + get_ring(coords)

    else:
        raise Exception(geojson_type + " not supported")
