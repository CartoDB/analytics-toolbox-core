# Copyright (c) 2021, CARTO

from __future__ import division
import geojson
from ..helper import PRECISION


def coords_mean(coords_list):
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
    if len(geom) == 0:
        raise Exception(
            'Invalid operation: Found empty point. Please check the input geometry'
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

    # Take the type of geometry
    coords = []

    if geom.type == 'GeometryCollection':
        for feature in geom.geometries:
            if feature.type == 'Polygon' or feature.type == 'MultiPolygon':
                coords += remove_end_polygon_point(feature.coordinates)
            else:
                coords += list(geojson.utils.coords(feature))
    elif geom.type == 'Polygon' or geom.type == 'MultiPolygon':
        coords = remove_end_polygon_point(geom.coordinates)
    else:
        coords = list(geojson.utils.coords(geom))

    return coords_mean(coords)
