# Copyright (c) 2020 Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

PRECISION = 14


def get_geom(geojson):
    """#TODO: Add description"""
    if geojson['type'] == 'Feature':
        return geojson['geometry']
    return geojson
