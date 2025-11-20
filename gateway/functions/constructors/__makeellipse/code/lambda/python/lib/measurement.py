# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

# flake8: noqa

from __future__ import division
from geojson import Feature, Point
from .helper import (
    length_to_radians,
    avg_earth_radius_km,
    convert_length,
    get_coord,
    PRECISION,
)
from math import asin, atan2, cos, degrees, log, pi, radians, sin, sqrt, tan
from .meta import coord_each

# -------------------------------#

# ----------- Centroid --------------#


def centroid(geojson, properties=None):
    """
    Takes one or more features and calculates the centroid using the mean of
    all vertices.

    :param geojson: Input features
    :param properties: Properties to be set to the output Feature point
    :return: Feature: Point feature which is the centroid of the given features

    Example:

    >>> from turfpy.measurement import centroid
    >>> from geojson import Polygon
    >>> polygon = Polygon([((-81, 41), (-88, 36), (-84, 31), (-80, 33), (-77, 39),
    (-81, 41))])
    >>> centroid(polygon)
    """
    d = {"x_sum": 0, "y_sum": 0, "length": 0}

    def _callback_coord_each(
        coord, coord_index, feature_index, multi_feature_index, geometry_index
    ):
        d["x_sum"] += coord[0]
        d["y_sum"] += coord[1]
        d["length"] += 1

    coord_each(geojson, _callback_coord_each)
    point = Point(
        (d["x_sum"] / d["length"], d["y_sum"] / d["length"]), precision=PRECISION
    )
    return Feature(geometry=point, properties=properties if properties else {})


# -------------------------------#

# ----------- Destination --------------#


def destination(origin, distance, bearing, options={}):
    """
    Takes a Point and calculates the location of a destination point given a distance in
    degrees, radians, miles, or kilometers and bearing in degrees.

    :param origin: Start point.
    :param distance: distance upto which the destination is from origin.
    :param bearing: Direction in which is the destination is from origin.
    :param options: Option like units of distance and properties to be passed to
        destination point feature, value
        for units are 'mi', 'km', 'deg' and 'rad'.
    :return: Feature: destination point in at the given distance and given direction.

    Example:

    >>> from turfpy.measurement import destination
    >>> from geojson import Point, Feature
    >>> origin = Feature(geometry=Point([-75.343, 39.984]))
    >>> distance = 50
    >>> bearing = 90
    >>> options = {'units': 'mi'}
    >>> destination(origin,distance,bearing,options)
    """
    coordinates1 = get_coord(origin)
    longitude1 = radians(float(coordinates1[0]))
    latitude1 = radians(float(coordinates1[1]))
    bearing_rad = radians(float(bearing))
    if "units" in options:
        radian = length_to_radians(distance, options["units"])
    else:
        radian = length_to_radians(distance)

    latitude2 = asin(
        (sin(latitude1) * cos(radian))
        + (cos(latitude1) * sin(radian) * cos(bearing_rad))
    )
    longitude2 = longitude1 + atan2(
        sin(bearing_rad) * sin(radian) * cos(latitude1),
        cos(radian) - sin(latitude1) * sin(latitude2),
    )

    lng = degrees(longitude2)
    lat = degrees(latitude2)

    point = Point((lng, lat), precision=PRECISION)

    return Feature(
        geometry=point,
        properties=options["properties"] if "properties" in options else {},
    )


# -------------------------------#

# ------------ rhumb bearing -----------#


def rhumb_bearing(start, end, final=False):
    """
    Takes two points and finds the bearing angle between them along a Rhumb line,
    i.e. the angle measured in degrees start the north line (0 degrees).

    :param start: Start Point or Point Feature.
    :param end: End Point or Point Feature.
    :param final: Calculates the final bearing if true
    :return: bearing from north in decimal degrees, between -180 and 180 degrees
        (positive clockwise)

    Example:

    >>> from turfpy.measurement import rhumb_bearing
    >>> from geojson import Feature, Point
    >>> start = Feature(geometry=Point((-75.343, 39.984)))
    >>> end = Feature(geometry=Point((-75.534, 39.123)))
    >>> rhumb_bearing(start, end, True)
    """
    if final:
        bear_360 = calculate_rhumb_bearing(get_coord(end), get_coord(start))
    else:
        bear_360 = calculate_rhumb_bearing(get_coord(start), get_coord(end))

    if bear_360 > 180:
        bear_180 = -1 * (360 - bear_360)
    else:
        bear_180 = bear_360

    return bear_180


def calculate_rhumb_bearing(fro, to):
    """#TODO: Add description"""
    phi1 = radians(fro[1])
    phi2 = radians(to[1])
    delta_lambda = radians(to[0] - fro[0])

    if delta_lambda > pi:
        delta_lambda -= 2 * pi
    if delta_lambda < -1 * pi:
        delta_lambda += 2 * pi

    delta_psi = log(tan(phi2 / 2 + pi / 4) / tan(phi1 / 2 + pi / 4))

    theta = atan2(delta_lambda, delta_psi)

    return (degrees(theta) + 360) % 360


# -------------------------------#

# ------------ rhumb destination -----------#


def rhumb_destination(origin, distance, bearing, options={}):
    """
    Returns the destination Point having travelled the given distance along a Rhumb line
    from the origin Point with the (varant) given bearing.

    :param origin: Starting Point
    :param distance: Distance from the starting point
    :param bearing: Varant bearing angle ranging from -180 to 180 degrees from north
    :param options: A dict of two values 'units' for the units of distance provided and
        'properties' that are to be passed to the Destination Feature Point
        Example :- {'units':'mi', 'properties': {"marker-color": "F00"}}
    :return: Destination Feature Point

    Example:

    >>> from turfpy.measurement import rhumb_destination
    >>> from geojson import Point, Feature
    >>> start = Feature(geometry=Point((-75.343, 39.984)),
    properties={"marker-color": "F00"})
    >>> distance = 50
    >>> bearing = 90
    >>> rhumb_destination(start, distance, bearing, {'units':'mi',
    'properties': {"marker-color": "F00"}})
    """
    was_negative_distance = distance < 0
    distance_in_meters = convert_length(abs(distance), options.get("units", "km"), "m")
    if was_negative_distance:
        distance_in_meters = -1 * (abs(distance_in_meters))
    coords = get_coord(origin)
    destination_point = _calculate_rhumb_destination(
        coords, distance_in_meters, bearing
    )
    return Feature(
        geometry=Point(destination_point, precision=PRECISION),
        properties=options.get("properties", ""),
    )


def _calculate_rhumb_destination(origin, distance, bearing, radius=None):
    if not radius:
        radius = avg_earth_radius_km

    delta = distance / radius
    lambda1 = origin[0] * pi / 180
    phi1 = radians(origin[1])
    theta = radians(bearing)
    delta_phi = delta * cos(theta)
    phi2 = phi1 + delta_phi

    if abs(phi2) > pi / 2:
        if phi2 > 0:
            phi2 = pi - phi2
        else:
            phi2 = -1 * pi - phi2

    delta_psi = log(tan(phi2 / 2 + pi / 4) / tan(phi1 / 2 + pi / 4))

    if abs(delta_psi) > 10e-12:
        q = delta_phi / delta_psi
    else:
        q = cos(phi1)

    delta_lambda = delta * sin(theta) / q

    lambda2 = lambda1 + delta_lambda

    return [((lambda2 * 180 / pi) + 540) % 360 - 180, phi2 * 180 / pi]


# -------------------------------#

# ------------ rhumb distance -----------#


def rhumb_distance(start, to, units="km"):
    """
    Calculates the distance along a rhumb line between two points in degrees, radians,
    miles, or kilometers.

    :param start: Start Point or Point Feature from which distance to be calculated.
    :param to: End Point or Point Feature upto which distance to be calculated.
    :param units: Units in which distance to be calculated, values can be 'deg', 'rad',
        'mi', 'km'
    :return: Distance calculated from provided start to end Point.

    Example:

    >>> from turfpy.measurement import rhumb_distance
    >>> from geojson import Point, Feature
    >>> start = Feature(geometry=Point((-75.343, 39.984)))
    >>> end = Feature(geometry=Point((-75.534, 39.123)))
    >>> rhumb_distance(start, end,'mi')
    """
    origin = get_coord(start)
    dest = get_coord(to)

    if dest[0] - origin[0] > 180:
        temp = -360
    elif origin[0] - dest[0] > 180:
        temp = 360
    else:
        temp = 0
    dest[0] += temp

    distance_in_meters = _calculate_rhumb_distance(origin, dest)
    ru_distance = convert_length(distance_in_meters, "m", units)
    return ru_distance


def _calculate_rhumb_distance(origin, destination_point, radius=None):
    if not radius:
        radius = avg_earth_radius_km
    phi1 = origin[1] * pi / 180
    phi2 = destination_point[1] * pi / 180
    delta_phi = phi2 - phi1
    delta_lambda = abs(destination_point[0] - origin[0]) * pi / 180

    if delta_lambda > pi:
        delta_lambda -= 2 * pi

    delta_psi = log(tan(phi2 / 2 + pi / 4) / tan(phi1 / 2 + pi / 4))
    if abs(delta_psi) > 10e-12:
        q = delta_phi / delta_psi
    else:
        q = cos(phi1)

    delta = sqrt(delta_phi * delta_phi + q * q * delta_lambda * delta_lambda)
    dist = delta * radius

    return dist
