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


def get_resolution(cell_id):
    """Returns the resolution (level) of a certain cell"""
    return s2sphere.CellId(cell_id).level()