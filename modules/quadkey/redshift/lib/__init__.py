from ._version import __version__  # noqa


def quadint_from_zxy(z, x, y):
    if z < 0 or z > 29:
        return None

    quadint = y
    quadint <<= z
    quadint |= x
    quadint <<= 5
    quadint |= z
    return quadint


def zxy_from_quadint(quadint):
    z = quadint & 31
    x = (quadint >> 5) & ((1 << z) - 1)
    y = quadint >> (z + 5)
    return {'z': z, 'x': x, 'y': y}


def sibling(quadint, direction):
    if quadint == 0:
        return 0
    direction = direction.lower()
    if direction not in ['left', 'right', 'up', 'down']:
        raise Exception('Wrong direction argument passed to sibling')

    tile = zxy_from_quadint(quadint)
    z = tile['z']
    x = tile['x']
    y = tile['y']
    tiles_per_level = 2 << (z - 1)
    if direction == 'left':
        x = x - 1 if x > 0 else tiles_per_level - 1

    if direction == 'right':
        x = x + 1 if x < tiles_per_level - 1 else 0

    if direction == 'up':
        y = y - 1 if y > 0 else tiles_per_level - 1

    if direction == 'down':
        y = y + 1 if y < tiles_per_level - 1 else 0

    return quadint_from_zxy(z, x, y)


def to_children(quadint, resolution):
    zxy = zxy_from_quadint(quadint)
    if zxy['z'] < 0 or zxy['z'] > 28:
        raise Exception('Wrong quadint zoom')

    if resolution < 0 or resolution <= zxy['z']:
        raise Exception('Wrong resolution')

    diff_z = resolution - zxy['z']
    mask = (1 << diff_z) - 1
    min_tile_x = zxy['x'] << diff_z
    max_tile_x = min_tile_x | mask
    min_tile_y = zxy['y'] << diff_z
    max_tile_y = min_tile_y | mask
    children = []
    for x in range(min_tile_x, max_tile_x + 1):
        for y in range(min_tile_y, max_tile_y + 1):
            children.append(quadint_from_zxy(resolution, x, y))
    return children


def to_parent(quadint, resolution):
    zxy = zxy_from_quadint(quadint)
    if zxy['z'] < 1 or zxy['z'] > 29:
        raise Exception('Wrong quadint zoom')

    if resolution < 0 or resolution >= zxy['z']:
        raise Exception('Wrong resolution')

    return quadint_from_zxy(
        resolution,
        zxy['x'] >> (zxy['z'] - resolution),
        zxy['y'] >> (zxy['z'] - resolution),
    )


def kring(origin, size):
    corner_quadint = origin
    # Traverse to top left corner
    for i in range(0, size):
        corner_quadint = sibling(corner_quadint, 'left')
        corner_quadint = sibling(corner_quadint, 'up')

    neighbors = []
    traversal_quadint = 0

    for j in range(0, size * 2 + 1):
        traversal_quadint = corner_quadint
        for i in range(0, size * 2 + 1):
            neighbors.append(traversal_quadint)
            traversal_quadint = sibling(traversal_quadint, 'right')
        corner_quadint = sibling(corner_quadint, 'down')

    return neighbors


def kring_distances(origin, size):
    corner_quadint = origin
    # Traverse to top left corner
    for i in range(0, size):
        corner_quadint = sibling(corner_quadint, 'left')
        corner_quadint = sibling(corner_quadint, 'up')

    neighbors = []
    traversal_quadint = 0

    for j in range(0, size * 2 + 1):
        traversal_quadint = corner_quadint
        for i in range(0, size * 2 + 1):
            neighbors.append(
                {
                    'index': traversal_quadint,
                    'distance': max(abs(i - size), abs(j - size)),  # Chebychev distance
                }
            )
            traversal_quadint = sibling(traversal_quadint, 'right')
        corner_quadint = sibling(corner_quadint, 'down')

    return neighbors


def quadint_from_location(long, lat, zoom):
    import mercantile

    if zoom < 0 or zoom > 29:
        raise Exception('Wrong zoom')

    lat = clip_number(lat, -85.05, 85.05)
    tile = mercantile.tile(long, lat, zoom)
    return quadint_from_zxy(zoom, tile.x, tile.y)


def quadint_from_quadkey(quadkey):
    import mercantile

    tile = mercantile.quadkey_to_tile(quadkey)
    return quadint_from_zxy(tile.z, tile.x, tile.y)


def quadkey_from_quadint(quadint):
    import mercantile

    tile = zxy_from_quadint(quadint)
    return mercantile.quadkey(tile['x'], tile['y'], tile['z'])


def bbox_quadkey(quadkey):
    import mercantile

    tile = mercantile.quadkey_to_tile(quadkey)
    bounds = mercantile.bounds(tile.x, tile.y, tile.z)
    return [bounds.west, bounds.south, bounds.east, bounds.north]


def bbox(quadint):
    import mercantile

    tile = zxy_from_quadint(quadint)
    bounds = mercantile.bounds(tile['x'], tile['y'], tile['z'])
    return [bounds.west, bounds.south, bounds.east, bounds.north]


def quadint_to_geojson(quadint):
    import mercantile

    tile = zxy_from_quadint(quadint)
    return mercantile.feature(mercantile.Tile(tile['x'], tile['y'], tile['z']))


def clip_number(num, a, b):
    return max(min(num, b), a)


def geojson_to_quadints(poly, limits):
    import tilecover

    return [
        quadint_from_zxy(int(tile[2]), int(tile[0]), int(tile[1]))
        for tile in tilecover.get_tiles(poly, limits)
    ]
