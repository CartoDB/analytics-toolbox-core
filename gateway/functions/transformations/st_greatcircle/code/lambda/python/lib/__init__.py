"""
ST_GREATCIRCLE function implementation.

Imports:
- great_circle from local great_circle module (function-specific)
- Shared utilities from transformations (truly shared)
"""

from .great_circle import great_circle

try:
    from lib.transformations import (
        PRECISION,
        wkt_from_geojson,
        parse_geojson_with_precision,
    )
except ImportError:
    from transformations import (
        PRECISION,
        wkt_from_geojson,
        parse_geojson_with_precision,
    )

__all__ = [
    "great_circle",
    "PRECISION",
    "wkt_from_geojson",
    "parse_geojson_with_precision",
]
