# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

from geojson import Feature, Point

PRECISION = 15


def load_geom(geom):
    from geojson import loads
    import json

    _geom = json.loads(geom)
    _geom['precision'] = PRECISION
    geom = json.dumps(_geom)
    return loads(geom)


def get_coord(coord):
    if not coord:
        raise Exception('coord is required')

    if (
        isinstance(coord, list)
        and len(coord) >= 2
        and not isinstance(coord[0], list)
        and not isinstance(coord[1], list)
    ):
        return coord
    elif (
        isinstance(coord, Feature)
        and coord['geometry']
        and coord['geometry']['type'] == 'Point'
    ):
        return coord['geometry']['coordinates']
    elif isinstance(coord, Point):
        return coord['coordinates']
    elif (
        isinstance(coord, dict)
        and coord['geometry']
        and coord['geometry']['type'] == 'Point'
    ):
        return coord['geometry']['coordinates']
    else:
        raise Exception('coord must be GeoJSON Point or an Array of numbers')


def get_geom(geojson):
    if geojson['type'] == 'Feature':
        return geojson['geometry']
    return geojson
