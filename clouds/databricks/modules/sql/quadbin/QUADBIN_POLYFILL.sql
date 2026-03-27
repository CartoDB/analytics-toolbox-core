----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Internal Python UDF that performs the polyfill computation on GeoJSON
-- strings. Inlines the quadbin Python library (v0.2.2) used by Redshift,
-- ensuring cross-cloud consistency. Databricks Python UDFs cannot import
-- external packages, so the library code is copied verbatim here.
-- Source: github.com/CartoDB/quadbin-py (v0.2.2)

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.__QUADBIN_POLYFILL_GEOJSON
(geojson STRING, resolution INT)
RETURNS ARRAY<BIGINT>
LANGUAGE PYTHON
AS $$
import json
import math

if geojson is None or resolution is None:
    return None

if resolution < 0 or resolution > 26:
    raise Exception('Invalid resolution, should be between 0 and 26')

# quadbin.main constants
HEADER = 0x4000000000000000
FOOTER = 0xFFFFFFFFFFFFF
B = [
    0x5555555555555555,
    0x3333333333333333,
    0x0F0F0F0F0F0F0F0F,
    0x00FF00FF00FF00FF,
    0x0000FFFF0000FFFF,
    0x00000000FFFFFFFF,
]
S = [1, 2, 4, 8, 16]


# quadbin.utils
def clip_number(num, lower, upper):
    return max(min(num, upper), lower)


def point_to_tile_fraction(longitude, latitude, resolution):
    z = resolution
    z2 = 1 << z
    sinlat = math.sin(latitude * math.pi / 180.0)
    x = z2 * (longitude / 360.0 + 0.5)
    yfraction = 0.5 - 0.25 * math.log((1 + sinlat) / (1 - sinlat)) / math.pi
    y = clip_number(z2 * yfraction, 0, z2 - 1)

    # Wrap Tile x
    x = x % z2
    x = x + z2 if x < 0 else x

    return (x, y, z)


def point_to_tile(longitude, latitude, resolution):
    x, y, z = point_to_tile_fraction(longitude, latitude, resolution)

    x = int(math.floor(x))
    y = int(math.floor(y))

    return (x, y, z)


def distinct(array):
    return list(set(array))


# quadbin.tilecover
def to_tile_hash(x, y, z):
    dim = 2 * (1 << z)
    return ((dim * y + x) * 32) + z


def from_tile_hash(tile_hash):
    z = int(tile_hash % 32)
    dim = 2 * (1 << z)
    xy = (tile_hash - z) / 32
    x = int(xy % dim)
    y = int(((xy - x) / dim) % dim)
    return (x, y, z)


def tiles_hashes_to_tiles(tiles_hashes):
    return [from_tile_hash(tile_hash) for tile_hash in distinct(tiles_hashes)]


def point_cover(coordinates, resolution):
    x, y, z = point_to_tile(coordinates[0], coordinates[1], resolution)
    return [to_tile_hash(x, y, z)]


def line_cover(coords, resolution, ring=None):
    tiles_hashes = []
    prev_x = None
    prev_y = None
    y = None

    for i in range(len(coords) - 1):
        start = point_to_tile_fraction(coords[i][0], coords[i][1], resolution)
        stop = point_to_tile_fraction(coords[i + 1][0], coords[i + 1][1], resolution)
        x0 = start[0]
        y0 = start[1]
        x1 = stop[0]
        y1 = stop[1]
        dx = x1 - x0
        dy = y1 - y0

        if dy == 0 and dx == 0:
            continue

        sx = 1 if dx > 0 else -1
        sy = 1 if dy > 0 else -1
        x = math.floor(x0)
        y = math.floor(y0)
        t_max_x = float("inf") if dx == 0 else abs(((1 if dx > 0 else 0) + x - x0) / dx)
        t_max_y = float("inf") if dy == 0 else abs(((1 if dy > 0 else 0) + y - y0) / dy)
        tdx = float("inf") if dx == 0 else abs(sx / dx)
        tdy = float("inf") if dy == 0 else abs(sy / dy)

        if x != prev_x or y != prev_y:
            tiles_hashes.append(to_tile_hash(x, y, resolution))
            if ring is not None and y != prev_y:
                ring.append([x, y])
            prev_x = x
            prev_y = y

        while t_max_x < 1 or t_max_y < 1:
            if t_max_x < t_max_y:
                t_max_x += tdx
                x += sx
            else:
                t_max_y += tdy
                y += sy

            tiles_hashes.append(to_tile_hash(x, y, resolution))
            if ring is not None and y != prev_y:
                ring.append([x, y])
            prev_x = x
            prev_y = y

    if ring and y == ring[0][1]:
        ring.pop()

    return tiles_hashes


def polygon_cover(geom, zoom):
    tiles_hashes = []
    intersections = []

    for i in range(len(geom)):
        ring = []
        tiles_hashes += line_cover(geom[i], zoom, ring)

        ring_length = len(ring)
        k = ring_length - 1
        for j in range(ring_length):
            m = (j + 1) % ring_length
            y = ring[j][1]

            #  add intersection if it's not local extremum or duplicate
            if (
                (y > ring[k][1] or y > ring[m][1])
                and (y < ring[k][1] or y < ring[m][1])
                and y != ring[m][1]
            ):
                intersections.append(ring[j])

            k = j

    intersections.sort(key=lambda tile: (tile[1], tile[0]))

    for i in range(0, len(intersections), 2):
        #  fill tiles between pairs of intersections
        y = intersections[i][1]
        for x in range(int(intersections[i][0] + 1), int(intersections[i + 1][0])):
            tiles_hashes.append(to_tile_hash(x, y, zoom))

    return tiles_hashes


def get_point_tiles_hashes(coordinates, resolution):
    return point_cover(coordinates, resolution)


def get_multipoint_tiles_hashes(coordinates, resolution):
    return [
        tile_hash
        for i in range(len(coordinates))
        for tile_hash in point_cover(coordinates[i], resolution)
    ]


def get_linestring_tiles_hashes(coordinates, resolution):
    return line_cover(coordinates, resolution)


def get_multilinestring_tiles_hashes(coordinates, resolution):
    return [
        tile_hash
        for i in range(len(coordinates))
        for tile_hash in line_cover(coordinates[i], resolution)
    ]


def get_polygon_tiles_hashes(coordinates, resolution):
    return polygon_cover(coordinates, resolution)


def get_multipolygon_tiles_hashes(coordinates, resolution):
    return [
        tile_hash
        for i in range(len(coordinates))
        for tile_hash in polygon_cover(coordinates[i], resolution)
    ]


def get_tiles(geometry, resolution):
    tiles_hashes = []
    geom_type = geometry["type"]
    geom_coordinates = geometry["coordinates"]

    get_tiles_hashes_function = {
        "Point": get_point_tiles_hashes,
        "MultiPoint": get_multipoint_tiles_hashes,
        "LineString": get_linestring_tiles_hashes,
        "MultiLineString": get_multilinestring_tiles_hashes,
        "Polygon": get_polygon_tiles_hashes,
        "MultiPolygon": get_multipolygon_tiles_hashes,
    }

    if geom_type not in get_tiles_hashes_function:
        raise Exception("Geometry type not implemented")

    tiles_hashes = get_tiles_hashes_function[geom_type](geom_coordinates, resolution)

    return tiles_hashes_to_tiles(tiles_hashes)


# quadbin.main
def tile_to_cell(tile):
    if tile is None:
        return None

    x, y, z = tile

    x = x << (32 - z)
    y = y << (32 - z)

    x = (x | (x << S[4])) & B[4]
    y = (y | (y << S[4])) & B[4]

    x = (x | (x << S[3])) & B[3]
    y = (y | (y << S[3])) & B[3]

    x = (x | (x << S[2])) & B[2]
    y = (y | (y << S[2])) & B[2]

    x = (x | (x << S[1])) & B[1]
    y = (y | (y << S[1])) & B[1]

    x = (x | (x << S[0])) & B[0]
    y = (y | (y << S[0])) & B[0]

    return HEADER | (1 << 59) | (z << 52) | ((x | (y << 1)) >> 12) | (FOOTER >> (z * 2))


def geometry_to_cells(geojson_str, resolution):
    tiles = []
    geometry = json.loads(geojson_str)

    if geometry["type"] == "GeometryCollection":
        for geom in geometry["geometries"]:
            tiles += [tile for tile in get_tiles(geom, resolution)]
        tiles = distinct(tiles)
    else:
        tiles = [tile for tile in get_tiles(geometry, resolution)]

    return [tile_to_cell(tile) for tile in tiles]


return geometry_to_cells(geojson, resolution)
$$;

-- Public function that accepts GEOMETRY(4326), matching other clouds.
-- Converts geometry to GeoJSON for the internal Python UDF.
CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_POLYFILL
(geom GEOMETRY(4326), resolution INT)
RETURNS ARRAY<BIGINT>
RETURN
@@DB_SCHEMA@@.__QUADBIN_POLYFILL_GEOJSON(ST_ASGEOJSON(geom), resolution);
