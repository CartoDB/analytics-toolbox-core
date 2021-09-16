# Copyright (c) 2020 Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

from __future__ import division
from dev_lib.spline import Spline
from geojson import Feature, LineString
from helper import get_geom
from math import floor


def bezier_spline(line, resolution=10000, sharpness=0.85):
    """
    Takes a line and returns a curved version by applying a Bezier spline algorithm
    :param line: LineString Feature which is used to draw the curve
    :param resolution: time in milliseconds between points
    :param sharpness: a measure of how curvy the path should be between splines
    :return: Curve as LineString Feature

    Example:

    >>> from geojson import LineString, Feature
    >>> from turfpy.transformation import bezier_spline
    >>> ls = LineString([(-76.091308, 18.427501),
    >>>                     (-76.695556, 18.729501),
    >>>                     (-76.552734, 19.40443),
    >>>                     (-74.61914, 19.134789),
    >>>                     (-73.652343, 20.07657),
    >>>                     (-73.157958, 20.210656)])
    >>> f = Feature(geometry=ls)
    >>> bezier_spline(f)
    """
    coords = []
    points = []
    geom = get_geom(line)

    for c in geom['coordinates']:
        points.append({'x': c[0], 'y': c[1]})

    spline = Spline(points_data=points, resolution=resolution, sharpness=sharpness)

    i = 0
    while i < spline.duration:
        pos = spline.pos(i)
        if floor(i / 100) % 2 == 0:
            coords.append((pos['x'], pos['y']))
        i = i + 10

    return Feature(geometry=LineString(coords))
