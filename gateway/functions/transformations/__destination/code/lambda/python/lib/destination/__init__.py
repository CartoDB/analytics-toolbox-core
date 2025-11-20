# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2021, CARTO

from .helper import length_to_radians
from math import radians, asin, cos, sin, atan2, degrees

from lib.transformations import PRECISION
import geojson


def destination(geom, distance, bearing, units):

    # Check if geom is a point
    if geom is None:
        raise Exception("geom is required")
    if geom.type != "Point":
        raise Exception("geom should be a Point")

    coords = list(geojson.utils.coords(geom))
    lon_orig = radians(float(coords[0][0]))
    lat_orig = radians(float(coords[0][1]))
    bearing_rad = radians(float(bearing))

    radian = length_to_radians(distance, units)

    lat_dest = asin(
        (sin(lat_orig) * cos(radian)) + (cos(lat_orig) * sin(radian) * cos(bearing_rad))
    )
    lon_dest = lon_orig + atan2(
        sin(bearing_rad) * sin(radian) * cos(lat_orig),
        cos(radian) - sin(lat_orig) * sin(lat_dest),
    )

    lon = degrees(lon_dest)
    lat = degrees(lat_dest)

    return geojson.Point((lon, lat), precision=PRECISION)
