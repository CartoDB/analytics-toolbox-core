# Copyright (c) 2021, CARTO

from __future__ import division
from scipy.spatial import Voronoi
import numpy as np
import geojson


def is_in_bbox(point, bottom_left, upper_right):
    """
    Point - Bounding box intersection test.
    :param point : Point to test
    :param bottom_left : bottom left corner of the bbox
    :param upper_right : upper right corner of the bbox
    :return: True if the point is inside the bbox, False otherwise
    """

    return (
        bottom_left[0] <= point[0]
        and upper_right[0] >= point[0]
        and bottom_left[1] <= point[1]
        and upper_right[1] >= point[1]
    )


def ray_line_intersection(ray_origin, ray_direction, line):
    """
    Ray - Line point of intersection.
    :param ray_origin : Origin of ray
    :param ray_direction : Destination of ray
    :param line : line to be intersected
    :return: t parameter indicating the
            intersection distance
    """

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


def clip_line_bbox(linestring, bottom_left, upper_right):
    """
    Line - Aligned axis bounding box clipping.
    :param linestring : Line to clip
    :param bottom_left : bottom left corner of the bbox
    :param upper_right : upper right corner of the bbox
    :return: List of points encoding the clipped line
    """

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


def voronoi_generic(geog, voronoi_type):
    """
    Computes a Voronoi diagram in a generic way.
    :param geog : Set of points
    :param voronoi_type : Type of diagrama (lines/poly)
    :return: A MultiPolygon/MultiLineString geojson
            with the diagram
    """
    # Take the type of geometry
    coords = []
    if geog.type != 'MultiPoint':
        raise Exception('Invalid operation: Input points parameter must be MultiPoint.')
    else:
        coords = list(geojson.utils.coords(geog))

    # Compute some bounds
    coords_array = np.array(coords)
    min_x = min(coords_array[:, 0])
    max_x = max(coords_array[:, 0])
    min_y = min(coords_array[:, 1])
    max_y = max(coords_array[:, 1])

    x_extent = abs(max_x - min_x) * 0.5
    y_extent = abs(max_y - min_y) * 0.5

    extent = min(x_extent, y_extent)

    bottom_left = [min_x - extent, min_y - extent]
    upper_right = [max_x + extent, max_y + extent]

    if voronoi_type == 'poly':
        # Complete the diagram with some extra points
        # to construct polygons with infinite ridges
        coords.append((-180, -90))
        coords.append((180, -90))
        coords.append((-180, 90))
        coords.append((180, 90))

    vor = Voronoi(coords)
    vor_vertices = vor.vertices

    if voronoi_type == 'lines':
        center = vor.points.mean(axis=0)
        ptp_bound = vor.points.ptp(axis=0)
        lines = []
        for pointidx, simplex in zip(vor.ridge_points, vor.ridge_vertices):
            simplex = np.asarray(simplex)
            if np.all(simplex >= 0):
                clipped_list = clip_line_bbox(
                    vor.vertices[simplex].tolist(), bottom_left, upper_right
                )

                if len(clipped_list) > 1:
                    lines.append(clipped_list)
            else:
                # finite end Voronoi vertex
                i = simplex[simplex >= 0][0]

                # direction
                d = vor.points[pointidx[1]] - vor.points[pointidx[0]]
                d /= np.linalg.norm(d)

                # normal
                n = np.array([-d[1], d[0]])

                # compute extension
                midpoint = vor.points[pointidx].mean(axis=0)
                direction = np.sign(np.dot(midpoint - center, n)) * n
                far_point = vor.vertices[i] + direction * ptp_bound.max()

                vertices_list = [vor.vertices[i].tolist()]
                vertices_list.append(far_point.tolist())
                clipped_list = clip_line_bbox(vertices_list, bottom_left, upper_right)

                if len(clipped_list) > 1:
                    lines.append(clipped_list)

        return geojson.MultiLineString(lines)

    else:
        lines = []
        for region in vor.regions:
            if -1 not in region and len(region) > 0:
                region.append(region[0])
                point_list = [list(vor_vertices[p]) for p in region]
                lines.append(point_list)

        return geojson.MultiPolygon([lines])
