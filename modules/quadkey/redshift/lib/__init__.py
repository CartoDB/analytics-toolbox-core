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


def clipNumber(num, a, b):
    return max(min(num, b), a)
