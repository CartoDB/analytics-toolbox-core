"""
ST_DESTINATION function implementation.

Imports:
- destination from local destination module (function-specific)
- Shared utilities from transformations (truly shared)
"""

from .destination import destination

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
    "destination",
    "PRECISION",
    "wkt_from_geojson",
    "parse_geojson_with_precision",
]
