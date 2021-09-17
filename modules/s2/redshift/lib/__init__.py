""""S2 helper lib

Mostly just a wrapper of the `s2sphere` library. However, some adjustments
have been made for compatibility with Redshift types:

- S2 uses UINT8s for IDs, ranging from 0 to 18446744073709551615, whereas
  Redshift has a maximum value of INT8 (signed) for integer, ranging from
  -9223372036854775808 to 9223372036854775807.
"""

from math import radians

import s2sphere

from .version import __version__

INT64_MAX = 9223372036854775807  # Max integer value in Redshift
UINT64_MAX = 18446744073709551615  # 2*INT64_MAX + 1. Used by S2


class InvalidResolution(Exception):
    pass


# Transform all values linearly
# def uint64_to_int64(uint64):
#     return uint64 - UINT64_MAX + INT64_MAX


# def int64_to_uint64(int64):
#     return int64 - INT64_MAX + UINT64_MAX

# Transform only overflow values
def uint64_to_int64(uint64):
    return uint64 if uint64 <= INT64_MAX else uint64 - UINT64_MAX - 1


# Transform only negative values
def int64_to_uint64(int64):
    return int64 if int64 >= 0 else int64 + UINT64_MAX + 1


def cell_from_int64_id(int64_id):
    return s2sphere.CellId(int64_to_uint64(int64_id))


def uint64_repr_from_id(int64_id):
    return cell_from_int64_id(int64_id).id()


def check_resolution(resolution):
    if not 0 <= resolution <= 30:
        err = 'Resolution must be between 0 and 30, got {r}'.format(r=resolution)
        raise InvalidResolution(err)


def check_valid_parent_resolution(resolution, parent_resolution):
    if parent_resolution > resolution:
        err = (
            'Parent resolution ({parent_resolution}) must be '
            + 'equal or smaller than cell resolution ({resolution})'
        ).format(parent_resolution=parent_resolution, resolution=resolution)
        raise InvalidResolution(err)


def check_valid_children_resolution(resolution, children_resolution):
    if children_resolution < resolution:
        err = (
            'Children resolution ({children_resolution}) must be '
            + 'equal or greater than cell resolution ({resolution})'
        ).format(children_resolution=children_resolution, resolution=resolution)
        raise InvalidResolution(err)


def longlat_as_int64_id(longitude, latitude, resolution):
    """Returns the S2 cell ID for a given longitude, latitude, and zoom resolution

    Returns a string since Redshift's max integer size is too small.

    Note: s2sphere always returns cells at zoom 30 so we have to get
    the parent at the specified resolution.
    """
    check_resolution(resolution)
    lat_lng = s2sphere.LatLng(radians(latitude), radians(longitude))
    cell = s2sphere.CellId.from_lat_lng(lat_lng).parent(resolution)

    return uint64_to_int64(cell.id())


def int64_id_to_token(int64_id):
    """Returns a unique string token for this cell id.

    This is a hex encoded version of the cell id with the right zeros stripped of.
    """
    cell = cell_from_int64_id(int64_id)

    return str(cell.to_token())


def get_resolution(int64_id):
    """Returns the resolution (level) of a certain cell"""
    return cell_from_int64_id(int64_id).level()


def to_parent(int64_id, resolution=None):
    """Returns the parent cell ID of a given cell ID for a specific resolution.

    A parent cell is the smaller resolution containing cell.

    By default, this function returns the direct parent (where parent resolution
    is child resolution - 1). However, an optional resolution argument can be passed
    with the desired parent resolution.
    """
    cell = cell_from_int64_id(int64_id)

    if resolution is not None:
        check_resolution(resolution)
        check_valid_parent_resolution(cell.level(), resolution)
        parent_cell = cell.parent(resolution)
    else:
        parent_cell = cell.parent()

    return uint64_to_int64(parent_cell.id())


def to_children(int64_id, resolution=None):
    """Returns a list of cell IDs, casted to string,  of the S2 cell's children
    for a specific resolution. A child cell is a cell of higher level of detail that is
    contained by the current cell. Each cell has four direct children by definition.

    By default, this function returns the direct children (where parent resolution
    is children resolution - 1). However, an optional resolution argument can be passed
    with the desired parent resolution. Note that the amount of children grows to
    the power of four per zoom level.
    """
    cell = cell_from_int64_id(int64_id)

    if resolution:
        check_valid_children_resolution(cell.level(), resolution)
        check_resolution(resolution)
        children_cells = cell.children(resolution)
    else:
        children_cells = cell.children()

    children_ids = [int(uint64_to_int64(child.id())) for child in children_cells]
    children_ids_str = (
        '[' + ','.join([str(child_id) for child_id in children_ids]) + ']'
    )

    return children_ids_str


def get_vertex_latlng(vertex):
    """Extract latitude and longitude in degrees from S2 Cell vertex"""
    vertex_latlng = s2sphere.LatLng.from_point(vertex)
    vertex_lat = vertex_latlng.lat().degrees
    vertex_lng = vertex_latlng.lng().degrees

    return (vertex_lat, vertex_lng)


def get_cell_boundary(int64_id):
    """Return the vertices of an s2 cell as WKT

    Note that S2 cell vertices must be joined by geodesic edges (great circles)"""
    cell = s2sphere.Cell(cell_from_int64_id(int64_id))

    latlngs = [get_vertex_latlng(cell.get_vertex(i)) for i in range(4)]
    latlngs.append(latlngs[0])  # Repeat first point for WKT

    verts_str = ', '.join([(str(lat) + ' ' + str(lng)) for lat, lng in latlngs])
    boundary_wkt = 'POLYGON (({verts_str}))'.format(verts_str=verts_str)

    return boundary_wkt


def polyfill_bbox(
    min_lng, min_lat, max_lng, max_lat, min_resolution=0, max_resolution=30
):
    """Polyfill a planar bounding box with compact s2 cells between resolution levels"""
    rc = s2sphere.RegionCoverer()

    rc.min_level = min_resolution
    rc.max_level = max_resolution

    lower_left = s2sphere.LatLng(radians(min_lat), radians(min_lng))
    upper_right = s2sphere.LatLng(radians(max_lat), radians(max_lng))
    rect = s2sphere.LatLngRect(lower_left, upper_right)

    cell_ids = [int(uint64_to_int64(cell.id())) for cell in rc.get_covering(rect)]

    cell_ids_str = '[' + ','.join([str(id) for id in cell_ids]) + ']'

    return cell_ids_str
