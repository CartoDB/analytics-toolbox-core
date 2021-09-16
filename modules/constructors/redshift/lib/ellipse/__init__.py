"""
This module implements some of the spatial analysis techniques and processes used to
understand the patterns and relationships of geographic features.
This is mainly inspired by turf.js.
link: http://turfjs.org/
"""
from __future__ import division
from geojson import Feature, Polygon
from helper import degrees_to_radians, get_coord
from math import pow, sqrt, pi, tan, cos, sin
from measurement import rhumb_destination
from transformation import transform_rotate


def ellipse(center, x_semi_axis, y_semi_axis, options={}):
    steps = 64
    if 'steps' in options:
        steps = options['steps']
    units = 'kilometers'
    units_mapping = {
        'miles': 'mi',
        'kilometers': 'km',
        'meters': 'm',
        'degrees': 'degrees',
    }
    if 'units' in options:
        units = options['units']
    angle = 0
    if 'angle' in options:
        angle = options['angle']

    # validation
    if center is None:
        raise Exception('center is required')
    if x_semi_axis is None:
        raise Exception('x_semi_axis is required')
    if y_semi_axis is None:
        raise Exception('y_semi_axis is required')
    if units not in units_mapping:
        raise Exception('non valid units')

    units = units_mapping[units]
    center_coords = get_coord(center)
    angle_rad = 0
    if units == 'degrees':
        angle_rad = degrees_to_radians(angle)
    else:
        x_semi_axis = rhumb_destination(center, x_semi_axis, 90, {'units': units})
        y_semi_axis = rhumb_destination(center, y_semi_axis, 0, {'units': units})
        x_semi_axis = get_coord(x_semi_axis)[0] - center_coords[0]
        y_semi_axis = get_coord(y_semi_axis)[1] - center_coords[1]

    coordinates = []
    for i in range(0, steps):
        step_angle = (i * -360) / steps
        x = (x_semi_axis * y_semi_axis) / sqrt(
            pow(y_semi_axis, 2) + pow(x_semi_axis, 2) * pow(get_tan_deg(step_angle), 2)
        )
        y = (
            0
            if pow(get_tan_deg(step_angle), 2) == 0
            else (x_semi_axis * y_semi_axis)
            / sqrt(
                pow(x_semi_axis, 2)
                + pow(y_semi_axis, 2) / pow(get_tan_deg(step_angle), 2)
            )
        )
        if step_angle < -90 and step_angle >= -270:
            x = -x
        if step_angle < -180 and step_angle >= -360:
            y = -y
        if units == 'degrees':
            newx = x * cos(angle_rad) + y * sin(angle_rad)
            newy = y * cos(angle_rad) - x * sin(angle_rad)
            x = newx
            y = newy

        coordinates.append([x + center_coords[0], y + center_coords[1]])

    coordinates.append(coordinates[0])
    if units == 'degrees':
        return Feature(geometry=Polygon([coordinates]))
    else:
        return transform_rotate(
            Feature(geometry=Polygon([coordinates])), angle, mutate=True
        )


def get_tan_deg(deg):
    rad = (deg * pi) / 180
    return tan(rad)
