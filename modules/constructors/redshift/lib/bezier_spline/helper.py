# Copyright (c) 2020 Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

PRECISION = 15


def load_geom(geom):
    from geojson import loads
    import json

    _geom = json.loads(geom)
    _geom['precision'] = PRECISION
    geom = json.dumps(_geom)
    return loads(geom)


def get_geom(geojson):
    if geojson['type'] == 'Feature':
        return geojson['geometry']
    return geojson
