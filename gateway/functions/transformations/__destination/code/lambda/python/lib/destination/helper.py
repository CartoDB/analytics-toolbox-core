# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

from __future__ import division

AVG_EARTH_RADIUS_KM = 6371008.8
CONVERSIONS = {
    "kilometers": 0.001,
    "m": 1.0,
    "miles": 0.000621371192,
    "ft": 3.28084,
    "in": 39.370,
    "degrees": 1 / 111325,
    "cen": 100,
    "radians": 1 / AVG_EARTH_RADIUS_KM,
    "naut": 0.000539956803,
    "yd": 0.914411119,
}


def length_to_radians(distance, unit="kilometres"):
    """Convert distance to radians based on unit."""
    if unit not in CONVERSIONS:
        raise Exception("unit is invalid")
    b = distance / (CONVERSIONS[unit] * AVG_EARTH_RADIUS_KM)
    return b
