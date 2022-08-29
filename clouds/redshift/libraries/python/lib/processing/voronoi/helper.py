# Copyright (c) 2021, CARTO

from __future__ import division
from math import atan2
import numpy as np


# Point helper methods
def is_in_bbox(point, bottom_left, upper_right):
    return (
        bottom_left[0] <= point[0]
        and upper_right[0] >= point[0]
        and bottom_left[1] <= point[1]
        and upper_right[1] >= point[1]
    )


# LineString helper methods
def ray_line_intersection(ray_origin, ray_direction, line):
    ray_array = np.array(ray_origin)
    p1_array = np.array(line[0])
    p2_array = np.array(line[1])
    v1 = ray_array - p1_array
    v2 = p2_array - p1_array
    v3 = np.array([-ray_direction[1], ray_direction[0]])

    dot = np.dot(v2, v3)

    if abs(dot) < 1e-5:
        return -1.0
    t1 = np.cross(v2, v1) / dot
    t2 = np.dot(v1, v3) / dot
    if t1 >= 0.0 and (t2 >= 0.0 and t2 <= 1.0):
        return t1

    return -1.0


def clip_segment_bbox(linestring, bottom_left, upper_right):
    new_line = []

    if len(linestring) == 2:
        t = np.array(linestring[1]) - np.array(linestring[0])
        direction = t / np.linalg.norm(t)

        origin_in = is_in_bbox(linestring[0], bottom_left, upper_right)
        destination_in = is_in_bbox(linestring[1], bottom_left, upper_right)

        if not origin_in and not destination_in:
            return new_line

        if origin_in:
            new_line.append(linestring[0])

        if origin_in and destination_in:
            new_line.append(linestring[1])
            return new_line

        else:
            t_intersections = []

            # bottom border
            border = [bottom_left, [upper_right[0], bottom_left[1]]]
            t = ray_line_intersection(linestring[0], direction, border)
            if t > -1.0:
                t_intersections.append(t)

            # left border
            border = [bottom_left, [bottom_left[0], upper_right[1]]]
            t = ray_line_intersection(linestring[0], direction, border)
            if t > -1.0:
                t_intersections.append(t)

            # right border
            border = [[upper_right[0], bottom_left[1]], upper_right]
            t = ray_line_intersection(linestring[0], direction, border)
            if t > -1.0:
                t_intersections.append(t)
            # upper border
            border = [[bottom_left[0], upper_right[1]], upper_right]
            t = ray_line_intersection(linestring[0], direction, border)
            if t > -1.0:
                t_intersections.append(t)

            t_sorted = np.sort(np.array(t_intersections))

            origin = np.array(linestring[0])
            destination = np.array(linestring[1])
            t_destination = (destination[0] - origin[0]) / direction[0]

            for intersection in t_sorted:
                if intersection < t_destination:
                    new_point = origin + direction * intersection
                    new_line.append(new_point.tolist())

            if destination_in:
                new_line.append(linestring[1])

    return new_line


def segment_segment_intersection(segment1, segment2):
    origin = np.array(segment1[0])
    destination = np.array(segment1[1])
    t = destination - origin
    direction = t / np.linalg.norm(t)

    t_intersection = ray_line_intersection(origin, direction, segment2)
    dir_factor = 1 if np.allclose(direction[0], 0) else 0
    t_destination = (destination[dir_factor] - origin[dir_factor]) / direction[
        dir_factor
    ]

    if t_intersection < t_destination and t_intersection > 0:
        return [origin + direction * t_intersection]

    return []


def triangle_area2(point_1, point_2, point_3):
    return (
        point_1[0] * point_2[1]
        - point_1[1] * point_2[0]
        + point_2[0] * point_3[1]
        - point_2[1] * point_3[0]
        + point_3[0] * point_1[1]
        - point_3[1] * point_1[0]
    )


def left(point_1, point_2, point_3):
    return triangle_area2(point_1, point_2, point_3) > 0


# Polygon helper methods


def order_clockwise(polygon, direction):

    center_x = 0
    center_y = 0

    for p in polygon:
        center_x += p[0]
        center_y += p[1]

    if len(polygon) > 0:
        center_x /= len(polygon)
        center_y /= len(polygon)

        polygon.sort(
            key=lambda x: atan2(x[1] - center_y, x[0] - center_x), reverse=direction
        )

    return polygon


def point_in_convex_polygon(point, polygon):
    for i in range(len(polygon) - 1):
        if left(point, polygon[i], polygon[i + 1]):
            return False

    return True


def polygon_polygon_intersection(poly1, poly2):
    clipped_polygon = []
    poly1 = order_clockwise(poly1[:-1], True)
    poly2 = order_clockwise(poly2[:-1], True)
    poly1.append(poly1[0])
    poly2.append(poly2[0])

    # Take points of poly1 inside poly2
    for p in poly1[:-1]:
        if point_in_convex_polygon(p, poly2):
            clipped_polygon.append(p)

    # Take points of poly1 inside poly2
    for p in poly2[:-1]:
        if point_in_convex_polygon(p, poly1):
            clipped_polygon.append(p)

    # Detect collisions
    for i in range(len(poly1) - 1):
        line1 = [poly1[i], poly1[i + 1]]
        for j in range(len(poly2) - 1):
            line2 = [poly2[j], poly2[j + 1]]
            point = segment_segment_intersection(line1, line2)
            if len(point) > 0:
                point_list = point[0].tolist()
                clipped_polygon.append(point_list)

    if len(clipped_polygon) > 0:
        clipped_polygon = order_clockwise(clipped_polygon, False)
        clipped_polygon.append(clipped_polygon[0])

    return clipped_polygon
