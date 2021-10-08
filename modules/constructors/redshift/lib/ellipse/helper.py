# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

from __future__ import division
from geojson import Feature, Point
from math import pi

PRECISION = 15

avg_earth_radius_km = 6371008.8
conversions = {
    'km': 0.001,
    'm': 1.0,
    'mi': 0.000621371192,
    'ft': 3.28084,
    'in': 39.370,
    'deg': 1 / 111325,
    'cen': 100,
    'rad': 1 / avg_earth_radius_km,
    'naut': 0.000539956803,
    'yd': 0.914411119,
}


def load_geom(geom):
    from geojson import loads
    import json

    _geom = json.loads(geom)
    _geom['precision'] = PRECISION
    geom = json.dumps(_geom)
    return loads(geom)


def convert_length(length, original_unit='km', final_unit='km'):
    if length < 0:
        raise Exception('length must be a positive number')
    return radians_to_length(length_to_radians(length, original_unit), final_unit)


def length_to_radians(distance, unit='km'):
    if unit not in conversions:
        raise Exception(unit + ' unit is invalid')
    b = distance / (conversions[unit] * avg_earth_radius_km)
    return b


def radians_to_length(radians, unit='km'):
    if unit not in conversions:
        raise Exception(unit + ' unit is invalid')
    b = radians * conversions[unit] * avg_earth_radius_km
    return b


def degrees_to_radians(degrees):
    radians = degrees % 360
    return (radians * pi) / 180


def get_coord(coord):
    if not coord:
        raise Exception('coord is required')

    if (
        isinstance(coord, list)
        and len(coord) >= 2
        and not isinstance(coord[0], list)
        and not isinstance(coord[1], list)
    ):
        return coord
    elif (
        isinstance(coord, Feature)
        and coord['geometry']
        and coord['geometry']['type'] == 'Point'
    ):
        return coord['geometry']['coordinates']
    elif isinstance(coord, Point):
        return coord['coordinates']
    elif (
        isinstance(coord, dict)
        and coord['geometry']
        and coord['geometry']['type'] == 'Point'
    ):
        return coord['geometry']['coordinates']
    else:
        raise Exception('coord must be GeoJSON Point or an Array of numbers')
