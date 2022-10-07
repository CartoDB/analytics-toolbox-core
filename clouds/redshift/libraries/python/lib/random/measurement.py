# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

from helper import get_coord, get_geom


def boolean_point_in_polygon(point, polygon, ignore_boundary=False):
    """Take a Point or a Point Feature and Polygon or Polygon Feature as input and returns
    True if Point is in given Feature.
    """
    if not point:
        raise Exception('point is required')
    if not polygon:
        raise Exception('polygon is required')

    pt = get_coord(point)
    geom = get_geom(polygon)
    geo_type = geom['type']
    bbox = polygon.get('bbox', None)
    polys = geom['coordinates']

    if bbox and not in_bbox(pt, bbox):
        return False

    if geo_type == 'Polygon':
        polys = [polys]

    inside_poly = False

    for i in range(0, len(polys)):
        if in_ring(pt, polys[i][0], ignore_boundary):
            in_hole = False
            k = 1
            while k < len(polys[i]) and not in_hole:
                if in_ring(pt, polys[i][k], not ignore_boundary):
                    in_hole = True
                k += 1
            if not in_hole:
                inside_poly = True

    return inside_poly


def in_ring(pt, ring, ignore_boundary):
    is_inside = False
    if ring[0][0] == ring[len(ring) - 1][0] and ring[0][1] == ring[len(ring) - 1][1]:
        ring = ring[0 : len(ring) - 1]
    j = len(ring) - 1
    for i in range(0, len(ring)):
        xi = ring[i][0]
        yi = ring[i][1]
        xj = ring[j][0]
        yj = ring[j][1]
        on_boundary = (
            (pt[1] * (xi - xj) + yi * (xj - pt[0]) + yj * (pt[0] - xi) == 0)
            and ((xi - pt[0]) * (xj - pt[0]) <= 0)
            and ((yi - pt[1]) * (yj - pt[1]) <= 0)
        )
        if on_boundary:
            return not ignore_boundary
        intersect = ((yi > pt[1]) != (yj > pt[1])) and (
            pt[0] < (xj - xi) * (pt[1] - yi) / (yj - yi) + xi
        )
        if intersect:
            is_inside = not is_inside
        j = i
    return is_inside


def in_bbox(pt, bbox):
    return bbox[0] <= pt[0] <= bbox[2] and bbox[1] <= pt[1] <= bbox[3]
