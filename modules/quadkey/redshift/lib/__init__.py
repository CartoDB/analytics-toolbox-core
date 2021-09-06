import numpy as np
import mercantile

_version__ = '1.0.0'


def quadintFromZXY(z, x, y):
    if z < 0 or z > 29:
        return None

    quadint = np.int64(y)
    quadint <<= z
    quadint |= x
    quadint <<= 5
    quadint |= z
    return quadint


def ZXYFromQuadint(quadint):
    quadint = np.int64(quadint)
    z = quadint & 31
    x = (quadint >> 5) & ((1 << z) - 1)
    y = quadint >> (z + 5)
    return {'z': z, 'x': x, 'y': y}


def toChildren(quadint, resolution):
    zxy = ZXYFromQuadint(quadint)
    if zxy['z'] < 0 or zxy['z'] > 28:
        raise Exception('Wrong quadint zoom')

    if resolution < 0 or resolution <= zxy['z']:
        raise Exception('Wrong resolution')

    diffZ = resolution - zxy['z']
    mask = (1 << diffZ) - 1
    minTileX = zxy['x'] << diffZ
    maxTileX = minTileX | mask
    minTileY = zxy['y'] << diffZ
    maxTileY = minTileY | mask
    children = []
    for x in range(minTileX, maxTileX + 1):
        for y in range(minTileY, maxTileY + 1):
            children.append(quadintFromZXY(resolution, x, y))
    return children


def toParent(quadint, resolution):
    zxy = ZXYFromQuadint(quadint)
    if zxy['z'] < 1 or zxy['z'] > 29:
        raise Exception('Wrong quadint zoom')

    if resolution < 0 or resolution >= zxy['z']:
        raise Exception('Wrong resolution')

    return quadintFromZXY(
        resolution,
        zxy['x'] >> (zxy['z'] - resolution),
        zxy['y'] >> (zxy['z'] - resolution),
    )


def quadintFromLocation(long, lat, zoom):
    if zoom < 0 or zoom > 29:
        raise Exception('Wrong zoom')

    lat = clipNumber(lat, -85.05, 85.05)
    tile = mercantile.tile(long, lat, zoom)
    return quadintFromZXY(zoom, tile.x, tile.y)


def quadintFromQuadkey(quadkey):
    tile = mercantile.quadkey_to_tile(quadkey)
    return quadintFromZXY(tile.z, tile.x, tile.y)


def quadkeyFromQuadint(quadint):
    tile = ZXYFromQuadint(quadint)
    return mercantile.quadkey(tile['x'], tile['y'], tile['z'])


def bbox(quadint):
    tile = ZXYFromQuadint(quadint)
    return mercantile.bounds(tile['x'], tile['y'], tile['z'])


def quadintToGeoJSON(quadint):
    tile = ZXYFromQuadint(quadint)
    return mercantile.feature(mercantile.Tile(tile['x'], tile['y'], tile['z']))


def clipNumber(num, a, b):
    return max(min(num, b), a)
