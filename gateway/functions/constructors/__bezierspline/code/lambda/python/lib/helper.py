# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

import json
import geojson

PRECISION = 15


def load_geom(geom_str):
    """
    Load geometry from GeoJSON string with precision.

    Args:
        geom_str: GeoJSON geometry string

    Returns:
        Parsed GeoJSON geometry dict
    """
    _geom = json.loads(geom_str)
    _geom["precision"] = PRECISION
    geom = json.dumps(_geom)
    return geojson.loads(geom)


def get_geom(geojson_obj):
    """Extract geometry from GeoJSON feature or geometry."""
    if geojson_obj["type"] == "Feature":
        return geojson_obj["geometry"]
    return geojson_obj
