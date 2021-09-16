"""
This module will have common utilities.
"""


def get_geom(geojson):
    """#TODO: Add description"""
    if geojson['type'] == 'Feature':
        return geojson['geometry']
    return geojson
