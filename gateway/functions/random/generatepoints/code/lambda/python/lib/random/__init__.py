import geojson
from geojson import Point, MultiPoint
from .helper import load_geom, PRECISION
from .measurement import boolean_point_in_polygon
import numpy as np
import random
import math


def bbox(geometry):
    coords = np.array(list(geojson.utils.coords(geometry)))
    return (
        coords[:, 0].min(),
        coords[:, 0].max(),
        coords[:, 1].min(),
        coords[:, 1].max(),
    )


def generatepoints(geom, npoints):
    geom = load_geom(geom)
    (x_min, x_max, y_min, y_max) = bbox(geom)
    degtorad = math.pi / 180.0
    radtodeg = 180.0 / math.pi
    siny_min = math.sin(y_min * degtorad)
    siny_max = math.sin(y_max * degtorad)
    valid_points = []
    while len(valid_points) < npoints:
        point = Point(
            (
                random.uniform(x_min, x_max),
                radtodeg * math.asin(random.uniform(siny_min, siny_max)),
            ),
            precision=PRECISION,
        )
        if boolean_point_in_polygon(point, geom):
            valid_points.append(point)
    if len(valid_points) == 1:
        return geojson.dumps(Point(valid_points[0]))
    else:
        return geojson.dumps(MultiPoint(valid_points))
