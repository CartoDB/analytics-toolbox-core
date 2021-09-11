import json
import math

import s2sphere

# from shapely import wkt
from shapely.geometry import mapping, Polygon

VERSION = '1.0.0'


def lnglat_as_id(longitude, latitude, resolution):
    """Returns the S2 cell ID for a given longitude, latitude, and zoom resolution

    Note: s2sphere always returns cells at zoom resolution 30
    """
    lat_lng = s2sphere.LatLng(math.radians(latitude), math.radians(longitude))
    cell = s2sphere.CellId.from_lat_lng(lat_lng).parent(resolution)

    return cell.id()


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
    parent_cell = (cell.parent(resolution) if resolution else cell.parent())

    return parent_cell.id()


def to_children(cell_id, resolution=None):
    """Returns a string of comma-separated cell IDs of the S2 cell's children
    for a specific resolution. A child cell is a cell of higher level of detail
    that is contained by the current cell. Each cell has four direct children by definition.

    By default, this function returns the direct children (where parent resolution
    is children resolution - 1). However, an optional resolution argument can be passed
    with the desired parent resolution. Note that the amount of children grows to
    the power of four per zoom level.
    """
    cell = s2sphere.CellId(cell_id)
    children_cells = (cell.children(resolution) if resolution else cell.children())
    children_cell_ids = ','.join([str(child.id()) for child in children_cells])

    return children_cell_ids


def get_cell_bounds(cell_id):
    """Return the vertices of an s2 cell.
    
    TO DO: Shapely can't be imported so we have to figure out a way
    of returning the data: text array, GeoJSON, WKT, etc"""
    cell = s2sphere.Cell(s2sphere.CellId(cell_id))
    
    verts = []
    for i in range(4):
        v = cell.get_vertex(i)
        v_ll = s2sphere.LatLng.from_point(v)
        v_lat = v_ll.lat().degrees
        v_lng = v_ll.lng().degrees
        
        # verts.append((v_lat, v_lng))
        verts.append(str(v_lng) + ',' + str(v_lat))
    
    # bounds_poly = Polygon(verts)

    # bounds_geojson = json.dumps(mapping(bounds_poly))
    # return bounds_geojson

    # bounds_wkt = wkt.dumps(bounds_poly)
    # return bounds_wkt

    verts_str = ' '.join(verts)
    return verts_str
