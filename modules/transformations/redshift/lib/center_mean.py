# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2021, CARTO

from __future__ import division
import geojson

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

    return geojson.Point((sum_x / total_features, sum_y / total_features))


def center_mean(geog):

    # validation
    if geog is None:
        raise Exception('geog is required')

    # Take the type of geometry
    coords = []
    if geog.type == 'GeometryCollection':
        coords = list(geojson.utils.coords(geog.geometries))
    else:
        coords = list(geojson.utils.coords(geog))

    return coords_mean(coords)
