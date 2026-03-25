----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Internal Python UDF that performs the polyfill computation on WKT/GeoJSON
-- strings. Uses Python because Databricks SQL lacks native geography
-- primitives (ST_INTERSECTS, ST_CONTAINS) needed for a pure SQL
-- implementation. BigQuery's SQL version relies on its GEOGRAPHY type.

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.__QUADBIN_POLYFILL_STRING
(geojson_or_wkt STRING, resolution INT)
RETURNS ARRAY<BIGINT>
LANGUAGE PYTHON
AS $$
import json
import math
import re

if geojson_or_wkt is None or resolution is None:
    return None

MIN_RESOLUTION = 0
MAX_RESOLUTION = 26

if resolution < MIN_RESOLUTION or resolution > MAX_RESOLUTION:
    raise Exception(
        f'Invalid resolution, should be between '
        f'{MIN_RESOLUTION} and {MAX_RESOLUTION}'
    )

HEADER = 0x4000000000000000
MODE_BIT = 1 << 59
PI = math.pi
MAX_LATITUDE = 89.0


def longlat_to_tile(lng, lat, z):
    num_tiles = 1 << z
    clamped_lat = max(-MAX_LATITUDE, min(MAX_LATITUDE, lat))
    x = int(num_tiles * ((lng / 360.0) + 0.5)) & (num_tiles - 1)
    y_frac = 0.5 - (
        math.log(math.tan(PI / 4.0 + clamped_lat / 2.0 * PI / 180.0))
        / (2 * PI)
    )
    y = int(max(0, min(num_tiles - 1, num_tiles * y_frac))) & (num_tiles - 1)
    return x, y


def tile_to_quadbin(z, x, y):
    quad_int = 0
    for i in range(z):
        quad_int |= ((x >> (z - 1 - i)) & 1) << (2 * (z - 1 - i))
        quad_int |= ((y >> (z - 1 - i)) & 1) << (2 * (z - 1 - i) + 1)
    unused_bits = (1 << (52 - z * 2)) - 1
    return HEADER | MODE_BIT | (z << 52) | (quad_int << (52 - z * 2)) | unused_bits


def tile_to_lng(x, z):
    return (x / (1 << z)) * 360.0 - 180.0


def tile_to_lat(y, z):
    n = PI - 2.0 * PI * y / (1 << z)
    return math.degrees(math.atan(math.sinh(n)))


def point_in_polygon(px, py, polygon_coords):
    inside = False
    n = len(polygon_coords)
    j = n - 1
    for i in range(n):
        xi, yi = polygon_coords[i]
        xj, yj = polygon_coords[j]
        if ((yi > py) != (yj > py)) and (
            px < (xj - xi) * (py - yi) / (yj - yi) + xi
        ):
            inside = not inside
        j = i
    return inside


def parse_ring(ring_str):
    coords = []
    for pair in ring_str.split(','):
        parts = pair.strip().split()
        if len(parts) >= 2:
            coords.append((float(parts[0]), float(parts[1])))
    return coords


def split_top_level_groups(text):
    """Split text by commas that are at depth 0 (outside all parens)."""
    groups = []
    depth = 0
    start = 0
    for i, ch in enumerate(text):
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        elif ch == ',' and depth == 0:
            groups.append(text[start:i].strip())
            start = i + 1
    tail = text[start:].strip()
    if tail:
        groups.append(tail)
    return groups


def parse_wkt_polygon_rings(body):
    """Parse the body inside POLYGON(...) into a list of rings."""
    ring_strs = re.findall(r'\(([^()]+)\)', body)
    rings = []
    for ring_str in ring_strs:
        coords = parse_ring(ring_str)
        if coords:
            rings.append(coords)
    return rings


def parse_geometry(input_str):
    input_str = input_str.strip()
    if input_str.startswith('{'):
        geojson = json.loads(input_str)
        geom_type = geojson.get('type', '')
        coords = geojson.get('coordinates', [])
        geometries = []
        if geom_type == 'Polygon':
            geometries.append(coords)
        elif geom_type == 'MultiPolygon':
            geometries.extend(coords)
        elif geom_type == 'GeometryCollection':
            for geom in geojson.get('geometries', []):
                sub = parse_geometry(json.dumps(geom))
                geometries.extend(sub)
        return geometries

    upper = input_str.upper()
    if upper.startswith('MULTIPOLYGON'):
        body = input_str[len('MULTIPOLYGON'):].strip()
        # Strip outermost parens: ((...),(...))
        if body.startswith('(') and body.endswith(')'):
            body = body[1:-1]
        polygon_groups = split_top_level_groups(body)
        geometries = []
        for group in polygon_groups:
            rings = parse_wkt_polygon_rings(group)
            if rings:
                geometries.append(rings)
        return geometries

    if upper.startswith('POLYGON'):
        body = input_str[len('POLYGON'):].strip()
        rings = parse_wkt_polygon_rings(body)
        if rings:
            return [rings]
        return []

    # Fallback: try as bare polygon rings
    rings = parse_wkt_polygon_rings(input_str)
    if rings:
        return [rings]
    return []


polygons = parse_geometry(geojson_or_wkt)
z = resolution
num_tiles = 1 << z
quadbin_set = set()

for polygon_rings in polygons:
    if not polygon_rings:
        continue
    outer_ring = polygon_rings[0]
    holes = polygon_rings[1:]

    lngs = [c[0] for c in outer_ring]
    lats = [c[1] for c in outer_ring]
    min_lng, max_lng = min(lngs), max(lngs)
    min_lat, max_lat = min(lats), max(lats)

    x_min, _ = longlat_to_tile(min_lng, max_lat, z)
    x_max, _ = longlat_to_tile(max_lng, min_lat, z)
    _, y_min = longlat_to_tile(min_lng, max_lat, z)
    _, y_max = longlat_to_tile(max_lng, min_lat, z)

    for tx in range(x_min, x_max + 1):
        for ty in range(y_min, y_max + 1):
            center_lng = tile_to_lng(tx + 0.5, z)
            center_lat = tile_to_lat(ty + 0.5, z)
            if point_in_polygon(center_lng, center_lat, outer_ring):
                in_hole = any(
                    point_in_polygon(center_lng, center_lat, h)
                    for h in holes
                )
                if not in_hole:
                    quadbin_set.add(tile_to_quadbin(z, tx, ty))

return list(quadbin_set)
$$;

-- Public function that accepts GEOMETRY(4326), matching other clouds.
CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_POLYFILL
(geom GEOMETRY(4326), resolution INT)
RETURNS ARRAY<BIGINT>
RETURN
@@DB_SCHEMA@@.__QUADBIN_POLYFILL_STRING(ST_ASTEXT(geom), resolution);
