from ._version import __version__  # noqa


def quadbin_from_zxy(z, x, y):
    x = x << (32 - z)
    y = y << (32 - z)

    b = [
        0x5555555555555555,
        0x3333333333333333,
        0x0F0F0F0F0F0F0F0F,
        0x00FF00FF00FF00FF,
        0x0000FFFF0000FFFF,
    ]
    s = [1, 2, 4, 8, 16]

    x = (x | (x << s[4])) & b[4]
    y = (y | (y << s[4])) & b[4]

    x = (x | (x << s[3])) & b[3]
    y = (y | (y << s[3])) & b[3]

    x = (x | (x << s[2])) & b[2]
    y = (y | (y << s[2])) & b[2]

    x = (x | (x << s[1])) & b[1]
    y = (y | (y << s[1])) & b[1]

    x = (x | (x << s[0])) & b[0]
    y = (y | (y << s[0])) & b[0]

    # -- | (mode << 59) | (mode_dep << 57)
    return (
        0x4000000000000000
        | (1 << 59)
        | (z << 52)
        | ((x | (y << 1)) >> 12)
        | (0xFFFFFFFFFFFFF >> (z * 2))
    )


def quadbin_to_zxy(quadbin):
    b = [
        0x5555555555555555,
        0x3333333333333333,
        0x0F0F0F0F0F0F0F0F,
        0x00FF00FF00FF00FF,
        0x0000FFFF0000FFFF,
        0x00000000FFFFFFFF,
    ]
    s = [1, 2, 4, 8, 16]

    # mode = (quadbin >> 59) & 7
    # extra = (quadbin >> 57) & 3
    z = quadbin >> 52 & 31
    q = (quadbin & 0xFFFFFFFFFFFFF) << 12
    x = q
    y = q >> 1
    x = x & b[0]
    y = y & b[0]

    x = (x | (x >> s[0])) & b[1]
    y = (y | (y >> s[0])) & b[1]

    x = (x | (x >> s[1])) & b[2]
    y = (y | (y >> s[1])) & b[2]

    x = (x | (x >> s[2])) & b[3]
    y = (y | (y >> s[2])) & b[3]

    x = (x | (x >> s[3])) & b[4]
    y = (y | (y >> s[3])) & b[4]

    x = (x | (x >> s[4])) & b[5]
    y = (y | (y >> s[4])) & b[5]

    x = x >> (32 - z)
    y = y >> (32 - z)
    return {'z': z, 'x': x, 'y': y}


def quadbin_is_valid(quadbin):
    mode = (quadbin >> 59) & 7
    z = quadbin >> 52 & 31
    header = 0x4000000000000000
    unused = 0xFFFFFFFFFFFFF >> (((quadbin >> 52) & 0x1F) * 2)
    return (
        quadbin >= 0
        and (quadbin & header == header)
        and mode in [0, 1, 2, 3, 4, 5, 6]
        and z >= 0
        and z <= 26
        and (quadbin & unused == unused)
    )


def sibling(quadbin, direction):
    direction = direction.lower()
    if direction not in ['left', 'right', 'up', 'down']:
        raise Exception('Wrong direction argument passed to sibling')

    tile = quadbin_to_zxy(quadbin)
    z = tile['z']
    x = tile['x']
    y = tile['y']
    if z == 0:
        return None
    tiles_per_level = 2 << (z - 1)
    if direction == 'left':
        if x > 0:
            x = x - 1
        else:
            return None

    if direction == 'right':
        if x < tiles_per_level - 1:
            x = x + 1
        else:
            return None

    if direction == 'up':
        if y > 0:
            y = y - 1
        else:
            return None

    if direction == 'down':
        if y < tiles_per_level - 1:
            y = y + 1
        else:
            return None

    return quadbin_from_zxy(z, x, y)


def to_children(quadbin, resolution):
    zxy = quadbin_to_zxy(quadbin)
    if resolution < 0 or resolution > 26 or resolution <= zxy['z']:
        raise Exception('Invalid resolution')

    diff_z = resolution - zxy['z']
    mask = (1 << diff_z) - 1
    min_tile_x = zxy['x'] << diff_z
    max_tile_x = min_tile_x | mask
    min_tile_y = zxy['y'] << diff_z
    max_tile_y = min_tile_y | mask
    children = []
    for x in range(min_tile_x, max_tile_x + 1):
        for y in range(min_tile_y, max_tile_y + 1):
            children.append(quadbin_from_zxy(resolution, x, y))
    return children


def to_parent(quadbin, resolution):
    zxy = quadbin_to_zxy(quadbin)
    if resolution < 0 or resolution >= zxy['z']:
        raise Exception('Invalid resolution')

    return (
        (quadbin & ~(0x1F << 52))
        | (resolution << 52)
        | (0xFFFFFFFFFFFFF >> (resolution * 2))
    )


def kring(origin, size):
    corner_quadbin = origin
    # Traverse to top left corner
    for i in range(0, size):
        corner_quadbin = sibling(corner_quadbin, 'left')
        corner_quadbin = sibling(corner_quadbin, 'up')

    neighbors = []
    traversal_quadbin = 0

    for j in range(0, size * 2 + 1):
        traversal_quadbin = corner_quadbin
        for i in range(0, size * 2 + 1):
            neighbors.append(traversal_quadbin)
            traversal_quadbin = sibling(traversal_quadbin, 'right')
        corner_quadbin = sibling(corner_quadbin, 'down')

    return neighbors


def kring_distances(origin, size):
    corner_quadbin = origin
    # Traverse to top left corner
    for i in range(0, size):
        corner_quadbin = sibling(corner_quadbin, 'left')
        corner_quadbin = sibling(corner_quadbin, 'up')

    neighbors = []
    traversal_quadbin = 0

    for j in range(0, size * 2 + 1):
        traversal_quadbin = corner_quadbin
        for i in range(0, size * 2 + 1):
            neighbors.append(
                {
                    'index': traversal_quadbin,
                    'distance': max(abs(i), abs(j)),  # Chebychev distance
                }
            )
            traversal_quadbin = sibling(traversal_quadbin, 'right')
        corner_quadbin = sibling(corner_quadbin, 'down')

    return neighbors


def quadbin_from_location(long, lat, zoom):
    import mercantile

    if zoom < 0 or zoom > 26:
        raise Exception('Invalid resolution; should be between 0 and 26')

    lat = clip_number(lat, -85.05, 85.05)
    tile = mercantile.tile(long, lat, zoom)
    return quadbin_from_zxy(zoom, tile.x, tile.y)


def quadbin_from_quadkey(quadkey):
    import mercantile

    tile = mercantile.quadkey_to_tile(quadkey)
    return quadbin_from_zxy(tile.z, tile.x, tile.y)


def quadkey_from_quadbin(quadbin):
    import mercantile

    tile = quadbin_to_zxy(quadbin)
    return mercantile.quadkey(tile['x'], tile['y'], tile['z'])


def bbox(quadbin):
    import mercantile

    tile = quadbin_to_zxy(quadbin)
    bounds = mercantile.bounds(tile['x'], tile['y'], tile['z'])
    return [bounds.west, bounds.south, bounds.east, bounds.north]


def quadbin_center(quadbin):
    import mercantile

    tile = quadbin_to_zxy(quadbin)
    bounds = mercantile.bounds(tile['x'], tile['y'], tile['z'])
    return ((bounds.west + bounds.east) / 2, (bounds.south + bounds.north) / 2)


def quadbin_to_geojson(quadbin):
    import mercantile

    tile = quadbin_to_zxy(quadbin)
    return mercantile.feature(mercantile.Tile(tile['x'], tile['y'], tile['z']))


def clip_number(num, a, b):
    return max(min(num, b), a)


def geojson_to_quadbins(poly, limits):
    import tilecover

    return [
        quadbin_from_zxy(int(tile[2]), int(tile[0]), int(tile[1]))
        for tile in tilecover.get_tiles(poly, limits)
    ]
