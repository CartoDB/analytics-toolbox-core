# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

from math import sqrt

# def define_projection(bbox):
#    [coord_x, coord_y] = center_bbox(bbox)
#    rotation = [-coord_x, -coord_y]
#    return geoAzimuthalEquidistant().rotate(rotation).scale(earthRadius)
#
#
# def center_bbox(bbox):
#    bbox_min = bbox.coordinates[0][0]
#    bbox_max = bbox.coordinates[0][2]
#
#    x = (bbox_min[0] + bbox_max[0]) / 2
#    y = (bbox_min[1] + bbox_max[1]) / 2
#
#    return [x, y]


def distance(p1, p2):
    return sqrt((p2[0] - p1[0]) * (p2[0] - p1[0]) + (p2[1] - p1[1]) * (p2[1] - p1[1]))
