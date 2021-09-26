# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2021, CARTO

import geojson
from helper import bearing, distance
from destination import destination

def along(geog, dist, units = "km"):
    """
    This function is used identify a Point at a specified distance along a LineString.
    :param line: LineString on which the point to be identified
    :param dist: Distance from the start of the LineString
    :param units: units of distance
    :return: Feature : Point at the distance on the LineString passed
    Example :
    >>> from turfpy.measurement import along
    >>> from geojson import LineString, Feature
    >>> ls = Feature(geometry=LineString([(-83, 30), (-84, 36), (-78, 41)]))
    >>> along(ls,200,'mi')
    """

    # Check if geog is a LineString
    if geog is None:
        raise Exception('geog is required')
    if geog.type != 'LineString':
        raise Exception('geog should be a LineString')

    coords = list(geojson.utils.coords(geog))

    travelled = 0
    for i in range(0, len(coords)):
        if dist >= travelled and i == (len(coords) - 1):
            break
        elif travelled >= dist:
            overshot = dist - travelled
            if not overshot:
                return geojson.Point(coords[i])
            else:
                direction = bearing(coords[i], coords[i - 1]) - 180
                interpolated = destination(
                    geojson.Point(coords[i]), overshot, direction, units
                )
                return interpolated
        else:

            travelled += distance(
                coords[i],
                coords[i + 1],
                units
            )


    return geojson.Point(coords[len(coords) - 1])