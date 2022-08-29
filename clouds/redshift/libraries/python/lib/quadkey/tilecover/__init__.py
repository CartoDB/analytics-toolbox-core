# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2021, CARTO

from __future__ import division
import math

d2r = math.pi / 180


def get_tiles(geom, limits):
    import mercantile

    i = None
    tile = None
    coords = geom['coordinates']
    min_zoom = limits['min_zoom']
    max_zoom = limits['max_zoom']
    tile_hash = {}
    tiles = []

    if geom['type'] == 'Point':
        return [mercantile.tile(coords[0], coords[1], max_zoom)]
    elif geom['type'] == 'MultiPoint':
        for i in range(0, len(coords)):
            tile = mercantile.tile(coords[i][0], coords[i][1], max_zoom)
            tile_hash[to_id(tile[0], tile[1], tile[2])] = True
    elif geom['type'] == 'LineString':
        line_cover(tile_hash, coords, max_zoom, None)
    elif geom['type'] == 'MultiLineString':
        for coord in coords:
            line_cover(tile_hash, coord, max_zoom, None)
    elif geom['type'] == 'Polygon':
        polygon_cover(tile_hash, tiles, coords, max_zoom)
    elif geom['type'] == 'MultiPolygon':
        for coord in coords:
            polygon_cover(tile_hash, tiles, coord, max_zoom)
    else:
        raise Exception('Geometry type not implemented')

    if min_zoom != max_zoom:
        #  sync tile hash and tile array so that both contain the same tiles
        tiles_length = len(tiles)
        append_hash_tiles(tile_hash, tiles)
        for i in range(0, tiles_length):
            t = tiles[i]
            tile_hash[to_id(t[0], t[1], t[2])] = True

        return merge_tiles(tile_hash, tiles, limits)

    append_hash_tiles(tile_hash, tiles)
    return tiles


def merge_tiles(tile_hash, tiles, limits):
    merged_tiles = []
    min_zoom = limits['min_zoom']
    max_zoom = limits['max_zoom']
    for z in range(max_zoom, min_zoom, -1):
        parent_tile_hash = {}
        parent_tiles = []
        tiles_length = len(tiles)
        for i in range(0, tiles_length):
            t = tiles[i]

            if t[0] % 2 == 0 and t[1] % 2 == 0:
                id2 = to_id(t[0] + 1, t[1], z)
                id3 = to_id(t[0], t[1] + 1, z)
                id4 = to_id(t[0] + 1, t[1] + 1, z)

                if tile_hash.get(id2) and tile_hash.get(id3) and tile_hash.get(id4):
                    tile_hash[to_id(t[0], t[1], t[2])] = False
                    tile_hash[id2] = False
                    tile_hash[id3] = False
                    tile_hash[id4] = False

                    parent_tile = [t[0] / 2, t[1] / 2, z - 1]

                    if z - 1 == limits.min_zoom:
                        merged_tiles.append(parent_tile)
                    else:
                        parent_tile_hash[to_id(t[0] / 2, t[1] / 2, z - 1)] = True
                        parent_tiles.append(parent_tile)

        for i in range(0, tiles_length):
            t = tiles[i]
            if tile_hash.get(to_id(t[0], t[1], t[2])):
                merged_tiles.append(t)

        tile_hash = parent_tile_hash
        tiles = parent_tiles

    return merged_tiles


def polygon_cover(tile_hash, tile_array, geom, zoom):
    intersections = []

    geom_length = len(geom)
    for i in range(0, geom_length):
        ring = []
        line_cover(tile_hash, geom[i], zoom, ring)

        j = 0
        ring_length = len(ring)
        k = ring_length - 1
        while j < ring_length:
            m = (j + 1) % ring_length
            y = ring[j][1]

            #  add interesction if it's not local extremum or duplicate
            if (
                (y > ring[k][1] or y > ring[m][1])
                and (y < ring[k][1] or y < ring[m][1])
                and y != ring[m][1]
            ):
                intersections.append(ring[j])

            k = j
            j += 1

    intersections.sort(key=lambda tile: (tile[1], tile[0]))

    intersections_length = len(intersections)
    for i in range(0, intersections_length, 2):
        #  fill tiles between pairs of intersections
        y = intersections[i][1]
        for x in range(int(intersections[i][0] + 1), int(intersections[i + 1][0])):
            id = to_id(x, y, zoom)
            if not tile_hash.get(id):
                tile_array.append([x, y, zoom])


def line_cover(tile_hash, coords, max_zoom, ring):
    prev_x = None
    prev_y = None
    y = None

    coords_length = len(coords)

    for i in range(0, coords_length - 1):
        start = point_to_tile_fraction(coords[i][0], coords[i][1], max_zoom)
        stop = point_to_tile_fraction(coords[i + 1][0], coords[i + 1][1], max_zoom)
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
        t_max_x = float('inf') if dx == 0 else abs(((1 if dx > 0 else 0) + x - x0) / dx)
        t_max_y = float('inf') if dy == 0 else abs(((1 if dy > 0 else 0) + y - y0) / dy)
        tdx = float('inf') if dx == 0 else abs(sx / dx)
        tdy = float('inf') if dy == 0 else abs(sy / dy)

        if x != prev_x or y != prev_y:
            tile_hash[to_id(x, y, max_zoom)] = True
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

            tile_hash[to_id(x, y, max_zoom)] = True
            if ring is not None and y != prev_y:
                ring.append([x, y])
            prev_x = x
            prev_y = y

    if ring and y == ring[0][1]:
        ring.pop()


def append_hash_tiles(hash, tiles):
    keys = list(hash.keys())
    for key in keys:
        tiles.append(from_id(+key))


def to_id(x, y, z):
    dim = 2 * (1 << int(z))
    return ((dim * y + x) * 32) + z


def from_id(id):
    z = id % 32
    dim = 2 * (1 << int(z))
    xy = (id - z) / 32
    x = xy % dim
    y = ((xy - x) / dim) % dim
    return [x, y, z]


# Tilebelt
def point_to_tile_fraction(lon, lat, z):
    sin = math.sin(lat * d2r)
    z2 = math.pow(2, z)
    x = z2 * (lon / 360 + 0.5)
    y = z2 * (0.5 - 0.25 * math.log((1 + sin) / (1 - sin)) / math.pi)

    #  Wrap Tile X
    x = x % z2
    if x < 0:
        x = x + z2
    return [x, y, z]
