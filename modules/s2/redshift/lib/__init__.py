import math

import s2sphere

VERSION = '1.0.0'


def lnglat_as_id(longitude, latitude, resolution):
    """Returns the S2 cell ID for a given longitude, latitude, and zoom resolution

    Note: s2sphere always returns cells at zoom resolution 30
    """
    lat_lng = s2sphere.LatLng(math.radians(latitude), math.radians(longitude))
    cell = s2sphere.CellId.from_lat_lng(lat_lng).parent(resolution)

    return cell.id()


def id_to_token(cell_id):
    """Returns a unique string token for this cell id.

    This is a hex encoded version of the cell id with the right zeros stripped of.
    """
    cell = s2sphere.CellId(cell_id)

    return str(cell.to_token())


def get_resolution(cell_id):
    """Returns the resolution (level) of a certain cell"""
    return s2sphere.CellId(cell_id).level()


def to_parent(cell_id, resolution=None):
    """Returns the parent cell ID of a given cell ID for a specific resolution.

    A parent cell is the smaller resolution containing cell.

    By default, this function returns the direct parent (where parent resolution
    is child resolution - 1). However, an optional resolution argument can be passed
    with the desired parent resolution.
    """
    cell = s2sphere.CellId(cell_id)
    parent_cell = cell.parent(resolution) if resolution else cell.parent()

    return parent_cell.id()


def to_children(cell_id, resolution=None):
    """Returns a string of comma-separated cell IDs of the S2 cell's children
    for a specific resolution. A child cell is a cell of higher level of detail that is
    contained by the current cell. Each cell has four direct children by definition.

    By default, this function returns the direct children (where parent resolution
    is children resolution - 1). However, an optional resolution argument can be passed
    with the desired parent resolution. Note that the amount of children grows to
    the power of four per zoom level.
    """
    cell = s2sphere.CellId(cell_id)
    children_cells = cell.children(resolution) if resolution else cell.children()
    children_cell_ids = ','.join([str(child.id()) for child in children_cells])

    return children_cell_ids


def get_vertex_latlng(vertex):
    """Extract latitude and longitude in degrees from S2 Cell vertex"""
    vertex_latlng = s2sphere.LatLng.from_point(vertex)
    vertex_lat = vertex_latlng.lat().degrees
    vertex_lng = vertex_latlng.lng().degrees

    return (vertex_lat, vertex_lng)


def get_cell_boundary(cell_id):
    """Return the vertices of an s2 cell as WKT

    Note that S2 cell vertices must be joined by geodesic edges (great circles)"""
    cell = s2sphere.Cell(s2sphere.CellId(cell_id))

    latlngs = [get_vertex_latlng(cell.get_vertex(i)) for i in range(4)]
    latlngs.append(latlngs[0])  # Repeat first point for WKT

    verts_str = ', '.join([(str(lat) + ' ' + str(lng)) for lat, lng in latlngs])
    boundary_wkt = 'POLYGON (({verts_str}))'.format(verts_str=verts_str)

    return boundary_wkt
