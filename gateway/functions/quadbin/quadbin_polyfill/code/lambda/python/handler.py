"""
CARTO Analytics Toolbox - QUADBIN_POLYFILL
Lambda handler for Redshift external function

This function fills a geometry with quadbin indices at a given resolution.
"""

import json
from typing import List, Optional

# Import lambda wrapper
# In Lambda: packaged as carto
# In local tests: conftest.py sets up the module alias
from carto.lambda_wrapper import redshift_handler


def quadbin_from_zxy(z: int, x: int, y: int) -> Optional[int]:
    """
    Convert z/x/y tile coordinates to quadbin index.

    Args:
        z: Zoom level (0-26)
        x: Tile x coordinate
        y: Tile y coordinate

    Returns:
        Quadbin index as integer, or None if invalid
    """
    if z < 0 or z > 26:
        return None
    if x < 0 or x >= (1 << z) or y < 0 or y >= (1 << z):
        return None

    # Quadbin encoding: interleave x and y bits
    quadbin = z
    for i in range(z):
        bit_x = (x >> (z - i - 1)) & 1
        bit_y = (y >> (z - i - 1)) & 1
        quadbin = (quadbin << 2) | (bit_y << 1) | bit_x

    return quadbin


def polyfill_geometry(geom_wkt: str, resolution: int) -> List[int]:
    """
    Fill a geometry with quadbins at the given resolution.

    Args:
        geom_wkt: WKT string representation of geometry
        resolution: Quadbin resolution level (0-26)

    Returns:
        List of quadbin indices covering the geometry

    Note:
        This is an EXAMPLE PLACEHOLDER implementation for demonstration purposes.
        In production, replace this with proper WKT parsing and polyfill algorithm:
        1. Parse WKT geometry (using shapely or similar)
        2. Get geometry bounding box
        3. Generate quadbins that intersect the geometry
        4. Return array of quadbin indices covering the area

        For reference implementations, see:
        - quadbin-py: https://github.com/CartoDB/quadbin-py
        - h3-py polyfill: https://github.com/uber/h3-py
    """
    if resolution < 0 or resolution > 26:
        return []

    # EXAMPLE PLACEHOLDER: Returns only a single quadbin at center
    # Replace this with actual polyfill algorithm
    center_tile = (1 << (resolution - 1)) if resolution > 0 else 0
    quadbin = quadbin_from_zxy(resolution, center_tile, center_tile)

    return [quadbin] if quadbin is not None else []


@redshift_handler
def process_quadbin_polyfill_row(row):
    """
    Process a single quadbin polyfill request row.

    Args:
        row: List containing [geometry_wkt, resolution] where:
            - geometry_wkt: WKT string representation of geometry
            - resolution: Quadbin resolution level (0-26)

    Returns:
        JSON string with quadbin indices array, or None for invalid inputs
    """
    # Handle invalid row structure
    if row is None or len(row) < 2:
        return None

    geom, resolution = row[0], row[1]

    # Handle null inputs
    if geom is None or resolution is None:
        return None

    # Process the geometry
    quadbins = polyfill_geometry(str(geom), int(resolution))
    # Return as JSON string - external function returns VARCHAR
    result_str = json.dumps(quadbins)
    return result_str


# Export as lambda_handler for AWS Lambda
lambda_handler = process_quadbin_polyfill_row
