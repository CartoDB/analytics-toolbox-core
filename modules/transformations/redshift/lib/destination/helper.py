# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

from __future__ import division
from math import sqrt, radians, sin, cos, atan2, degrees

AVG_EARTH_RADIUS_KM = 6371008.8
CONVERSIONS = {
    'kilometers': 0.001,
    'm': 1.0,
    'miles': 0.000621371192,
    'ft': 3.28084,
    'in': 39.370,
    'degrees': 1 / 111325,
    'cen': 100,
    'radians': 1 / AVG_EARTH_RADIUS_KM,
    'naut': 0.000539956803,
    'yd': 0.914411119,
}


def euclidean_distance(p1, p2):
    return sqrt((p2[0] - p1[0]) ** 2 + (p2[1] - p1[1]) ** 2)


def distance(p1, p2, units):
    """
    Calculates distance between two Points. A point is containing latitude and
    logitude in decimal degrees and ``unit`` is optional.
    It calculates distance in units such as kilometers, meters, miles, feet and inches.
    :param point1: first point; tuple of (latitude, longitude) in decimal degrees.
    :param point2: second point; tuple of (latitude, longitude) in decimal degrees.
    :param units: A string containing unit, E.g. kilometers = 'km', miles = 'mi',
        meters = 'm', feet = 'ft', inches = 'in'.
    :return: The distance between the two points in the requested unit, as a float.
    Example:
    >>> from turfpy import measurement
    >>> from geojson import Point, Feature
    >>> start = Feature(geometry=Point((-75.343, 39.984)))
    >>> end = Feature(geometry=Point((-75.534, 39.123)))
    >>> measurement.distance(start,end)
    """

    dlat = radians(p2[1] - p1[1])
    dlon = radians(p2[0] - p1[0])

    lat1 = radians(p1[1])
    lat2 = radians(p2[1])

    a = pow(sin(dlat / 2), 2) + pow(sin(dlon / 2), 2) * cos(lat1) * cos(lat2)
    b = 2 * atan2(sqrt(a), sqrt(1 - a))
    return radians_to_length(b, units)


def radians_to_length(radians, unit='kilometres'):
    """#TODO: Add description"""
    if unit not in CONVERSIONS:
        raise Exception('unit is invalid')
    b = radians * CONVERSIONS[unit] * AVG_EARTH_RADIUS_KM
    return b


def length_to_radians(distance, unit='kilometres'):
    """#TODO: Add description"""
    if unit not in CONVERSIONS:
        raise Exception('unit is invalid')
    b = distance / (CONVERSIONS[unit] * AVG_EARTH_RADIUS_KM)
    return b


def bearing(start, end, final=False):
    """
    Takes two Point and finds the geographic bearing between them.
    :param start: A object of :class:`Point` to represent start point.
    :param end: A object of :class:`Point` to represent end point.
    :param final: A boolean calculates the final bearing if True.
    :return: A float calculated bearing.
    Example:
    >>> from geojson import Point, Feature
    >>> from turfpy import measurement
    >>> start = Feature(geometry=Point((-75.343, 39.984)))
    >>> end = Feature(geometry=Point((-75.534, 39.123)))
    >>> measurement.bearing(start,end)
    """
    if final:
        return calculate_final_bearing(start, end)

    lon1 = radians(float(start[0]))
    lon2 = radians(float(end[0]))
    lat1 = radians(float(start[1]))
    lat2 = radians(float(end[1]))

    a = sin(lon2 - lon1) * cos(lat2)

    b = (cos(lat1) * sin(lat2)) - (sin(lat1) * cos(lat2) * cos(lon2 - lon1))
    return degrees(atan2(a, b))


def calculate_final_bearing(start, end):
    """#TODO: Add description"""
    bear = bearing(end, start)
    bear = (bear + 180) % 360
    return bear
