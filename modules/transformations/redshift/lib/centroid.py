# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2021, CARTO

import geojson
from helper import distance
from center_mean import coords_mean


def centroid_polygon(coords, area_poly):
    if area_poly == 0:
        return geojson.Point(0, 0)

    sum_x = 0
    sum_y = 0
    n_coords = len(coords)
    area6 = area_poly * 6

    for i in range(n_coords - 1):
        sum_x += (coords[i][0] + coords[i + 1][0]) * (
            coords[i][0] * coords[i + 1][1] - coords[i + 1][0] * coords[i][1]
        )
        sum_y += (coords[i][1] + coords[i + 1][1]) * (
            coords[i][0] * coords[i + 1][1] - coords[i + 1][0] * coords[i][1]
        )

    return geojson.Point((sum_x / area6, sum_y / area6))


def centroid_linestring(coords, length_line):
    if length_line == 0:
        return geojson.Point(0, 0)

    sum_x = 0
    sum_y = 0
    n_coords = len(coords)

    for i in range(n_coords - 1):
        segment_length = distance(coords[i], coords[i + 1])
        if segment_length == 0:
            continue

        mid_x = (coords[i][0] + coords[i + 1][0]) / 2
        sum_x += segment_length * mid_x
        mid_y = (coords[i][1] + coords[i + 1][1]) / 2
        sum_y += segment_length * mid_y

    return geojson.Point((sum_x / length_line, sum_y / length_line))


def centroid(geog, area_poly, length_line):

    # validation
    if geog is None:
        raise Exception('geog is required')
    if area_poly is None:
        raise Exception('area_poly is required')
    if length_line is None:
        raise Exception('length_line is required')

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
        return str(coords_mean(coords))
    elif geog.type == 'Polygon' or geog.type == 'MultiPolygon':
        return str(centroid_polygon(coords, area_poly))
    elif geog.type == 'LineString' or geog.type == 'MultiLineString':
        return str(centroid_linestring(coords, length_line))
    else:
        raise Exception('geometry type not supported')
