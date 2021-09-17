# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

import copy
from geojson import Point as GeoPoint

# from shapely import geometry as geometry

from helper import get_coord
from measurement import (
    centroid,
    rhumb_bearing,
    rhumb_destination,
    rhumb_distance,
)
from meta import coord_each


def transform_rotate(
    feature,
    angle,
    pivot=None,
    mutate=False,
):
    """
    Rotates any geojson Feature or Geometry of a specified angle,
    around its centroid or a given pivot
    point; all rotations follow the right-hand rule.

    :param feature: Geojson to be rotated.
    :param angle: angle of rotation (along the vertical axis),
        from North in decimal degrees, negative clockwise
    :param pivot: point around which the rotation will be performed
    :param mutate: allows GeoJSON input to be mutated
        (significant performance increase if True)
    :return: the rotated GeoJSON

    Example :-

    >>> from turfpy.transformation import transform_rotate
    >>> from geojson import Polygon, Feature
    >>> f = Feature(geometry=Polygon([[[0,29],[3.5,29],[2.5,32],[0,29]]]))
    >>> pivot = [0, 25]
    >>> transform_rotate(f, 10, pivot)
    """
    if not feature:
        raise Exception('geojson is required')

    if angle == 0:
        return feature

    if not pivot:
        pivot = centroid(feature)['geometry']['coordinates']

    if not mutate:
        feature = copy.deepcopy(feature)

    def _callback_coord_each(
        coord, coord_index, feature_index, multi_feature_index, geometry_index
    ):
        initial_angle = rhumb_bearing(GeoPoint(pivot), GeoPoint(coord))
        final_angle = initial_angle + angle
        distance = rhumb_distance(GeoPoint(pivot), GeoPoint(coord))
        new_coords = get_coord(
            rhumb_destination(GeoPoint(pivot), distance, final_angle)
        )
        coord[0] = new_coords[0]
        coord[1] = new_coords[1]

    coord_each(feature, _callback_coord_each)

    return feature
