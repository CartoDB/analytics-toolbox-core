# Copyright (c) 2021, CARTO
# http://en.wikipedia.org/wiki/Centroid

from __future__ import division
import geojson
from helper import euclidean_distance
from center_mean import coords_mean


def centroid_polygon(coords, n_precision):

    sum_x = 0
    sum_y = 0
    n_coords = len(coords)
    area = 0
    for i in range(n_coords - 1):
        sum_x += (coords[i][0] + coords[i + 1][0]) * (
            coords[i][0] * coords[i + 1][1] - coords[i + 1][0] * coords[i][1]
        )
        sum_y += (coords[i][1] + coords[i + 1][1]) * (
            coords[i][0] * coords[i + 1][1] - coords[i + 1][0] * coords[i][1]
        )
        area += coords[i][0] * coords[i + 1][1] - coords[i + 1][0] * coords[i][1]

    area /= 2

    return geojson.Point(
        (sum_x / (6 * area), sum_y / (6 * area)), precision=n_precision
    )


def centroid_linestring(coords, n_precision):

    sum_x = 0
    sum_y = 0
    n_coords = len(coords)
    length_line = 0

    for i in range(n_coords - 1):
        segment_length = euclidean_distance(coords[i], coords[i + 1])
        if segment_length == 0:
            continue

        mid_x = (coords[i][0] + coords[i + 1][0]) / 2
        sum_x += segment_length * mid_x
        mid_y = (coords[i][1] + coords[i + 1][1]) / 2
        sum_y += segment_length * mid_y
        length_line += segment_length

    return geojson.Point(
        (sum_x / length_line, sum_y / length_line), precision=n_precision
    )


def centroid(geom, n_precision):

    # validation
    if geom is None:
        raise Exception('geom is required')

    # Take the type of geometry
    coords = []
    if geom.type == 'GeometryCollection':
        coords = list(geojson.utils.coords(geom.geometries))
    else:
        coords = list(geojson.utils.coords(geom))

    if (
        geom.type == 'MultiPoint'
        or geom.type == 'Point'
        or geom.type == 'GeometryCollection'
    ):
        return coords_mean(coords)
    elif geom.type == 'Polygon' or geom.type == 'MultiPolygon':
        return centroid_polygon(coords, n_precision)
    elif geom.type == 'LineString' or geom.type == 'MultiLineString':
        return centroid_linestring(coords, n_precision)
    else:
        raise Exception('geometry type not supported')
