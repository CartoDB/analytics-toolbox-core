# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2021, CARTO

from helper import length_to_radians
from math import radians, asin, cos, sin, atan2, degrees
import geojson

def destination(geog, distance, bearing, units):

    # Check if geog is a point
    if geog is None:
        raise Exception('geog is required')
    if geog.type != 'Point':
        raise Exception('geog should be a Point')

    coords = list(geojson.utils.coords(geog))
    lon_orig = radians(float(coords[0][0]))
    lat_orig = radians(float(coords[0][1]))
    bearing_rad = radians(float(bearing))

    # Check units
#    if "units" in options:
#        radian = length_to_radians(distance, options["units"])
#    else:
#        radian = length_to_radians(distance)

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

    return geojson.Point((lon, lat))