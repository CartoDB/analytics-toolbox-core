# Copyright (c) 2021, CARTO
# http://en.wikipedia.org/wiki/Centroid

from __future__ import division
import geojson
from helper import euclidean_distance
from center_mean import coords_mean


def centroid_polygon(coords):

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

    return geojson.Point((sum_x / (6 * area), sum_y / (6 * area)))


def centroid_linestring(coords):

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

    return geojson.Point((sum_x / length_line, sum_y / length_line))


def centroid(geog):

    # validation
    if geog is None:
        raise Exception('geog is required')

    # Take the type of geometry
    coords = []
    if geog.type == 'GeometryCollection':
        coords = list(geojson.utils.coords(geog.geometries))
    else:
        coords = list(geojson.utils.coords(geog))

    if (
        geog.type == 'MultiPoint'
        or geog.type == 'Point'
        or geog.type == 'GeometryCollection'
    ):
        return coords_mean(coords)
    elif geog.type == 'Polygon' or geog.type == 'MultiPolygon':
        return centroid_polygon(coords)
    elif geog.type == 'LineString' or geog.type == 'MultiLineString':
        return centroid_linestring(coords)
    else:
        raise Exception('geometry type not supported')
