"""
Shared transformations utilities for gateway functions.

Contains only truly shared utilities used by multiple transformation functions:
- PRECISION: Standard precision for GeoJSON output
- wkt_from_geojson: Convert GeoJSON to WKT format
- parse_geojson_with_precision: Parse GeoJSON string with precision setting
- euclidean_distance: Calculate euclidean distance between two points
- coords_mean: Calculate mean of coordinates
- remove_end_polygon_point: Remove duplicate end point from polygon coordinates
- center_mean: Calculate mean center of geometry

Function-specific implementations should be in each function's directory,
not in this shared library.
"""

from .helper import (
    wkt_from_geojson,
    PRECISION,
    parse_geojson_with_precision,
    euclidean_distance,
    coords_mean,
    remove_end_polygon_point,
    center_mean,
)

__all__ = [
    "wkt_from_geojson",
    "PRECISION",
    "parse_geojson_with_precision",
    "euclidean_distance",
    "coords_mean",
    "remove_end_polygon_point",
    "center_mean",
]
