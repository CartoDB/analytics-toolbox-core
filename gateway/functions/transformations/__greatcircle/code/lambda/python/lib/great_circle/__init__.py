# Copyright (c) 2021, CARTO

import pygc
import geojson
from numpy import linspace

from lib.transformations import PRECISION


def great_circle(start_point, end_point, n_points):

    # Check if input are Points
    if start_point is None or end_point is None:
        raise Exception("geom is required")
    if start_point.type != "Point" or end_point.type != "Point":
        raise Exception("start_point and end_point should be a LineString")

    start_coords = list(geojson.utils.coords(start_point))
    end_coords = list(geojson.utils.coords(end_point))

    distance_dict = pygc.great_distance(
        start_latitude=start_coords[0][1],
        start_longitude=start_coords[0][0],
        end_latitude=end_coords[0][1],
        end_longitude=end_coords[0][0],
    )
    segments = linspace(start=0, stop=distance_dict["distance"], num=n_points)
    points_dict = pygc.great_circle(
        distance=segments,
        azimuth=distance_dict["azimuth"],
        latitude=start_coords[0][1],
        longitude=start_coords[0][0],
    )

    coords = []
    for i in range(n_points):
        coords.append([points_dict["longitude"][i], points_dict["latitude"][i]])

    return geojson.LineString(coords, precision=PRECISION)
