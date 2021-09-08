import math

d2r = math.pi / 180


def getTiles(geom, limits):
    import mercantile

    i = None
    tile = None
    coords = geom['coordinates']
    minZoom = limits['min_zoom']
    maxZoom = limits['max_zoom']
    tileHash = {}
    tiles = []

    if geom['type'] == 'Point':
        return [mercantile.tile(coords[0], coords[1], maxZoom)]
    elif geom['type'] == 'MultiPoint':
        for i in range(0, len(coords)):
            tile = mercantile.tile(coords[i][0], coords[i][1], maxZoom)
            tileHash[toID(tile[0], tile[1], tile[2])] = True
    elif geom['type'] == 'LineString':
        lineCover(tileHash, coords, maxZoom, None)
    elif geom['type'] == 'MultiLineString':
        for coord in coords:
            lineCover(tileHash, coord, maxZoom, None)
    elif geom['type'] == 'Polygon':
        polygonCover(tileHash, tiles, coords, maxZoom)
    elif geom['type'] == 'MultiPolygon':
        for coord in coords:
            polygonCover(tileHash, tiles, coord, maxZoom)
    else:
        raise Exception('Geometry type not implemented')

    if minZoom != maxZoom:
        #  sync tile hash and tile array so that both contain the same tiles
        tiles_length = len(tiles)
        appendHashTiles(tileHash, tiles)
        for i in range(0, tiles_length):
            t = tiles[i]
            tileHash[toID(t[0], t[1], t[2])] = True

        return mergeTiles(tileHash, tiles, limits)

    appendHashTiles(tileHash, tiles)
    return tiles


def mergeTiles(tileHash, tiles, limits):
    mergedTiles = []
    minZoom = limits['min_zoom']
    maxZoom = limits['max_zoom']
    for z in range(maxZoom, minZoom, -1):
        parentTileHash = {}
        parentTiles = []
        tiles_length = len(tiles)
        for i in range(0, tiles_length):
            t = tiles[i]

            if t[0] % 2 == 0 and t[1] % 2 == 0:
                id2 = toID(t[0] + 1, t[1], z)
                id3 = toID(t[0], t[1] + 1, z)
                id4 = toID(t[0] + 1, t[1] + 1, z)

                if tileHash.get(id2) and tileHash.get(id3) and tileHash.get(id4):
                    tileHash[toID(t[0], t[1], t[2])] = False
                    tileHash[id2] = False
                    tileHash[id3] = False
                    tileHash[id4] = False

                    parentTile = [t[0] / 2, t[1] / 2, z - 1]

                    if z - 1 == limits.min_zoom:
                        mergedTiles.append(parentTile)
                    else:
                        parentTileHash[toID(t[0] / 2, t[1] / 2, z - 1)] = True
                        parentTiles.append(parentTile)

        for i in range(0, tiles_length):
            t = tiles[i]
            if tileHash.get(toID(t[0], t[1], t[2])):
                mergedTiles.append(t)

        tileHash = parentTileHash
        tiles = parentTiles

    return mergedTiles


def polygonCover(tileHash, tileArray, geom, zoom):
    intersections = []

    geom_length = len(geom)
    for i in range(0, geom_length):
        ring = []
        lineCover(tileHash, geom[i], zoom, ring)

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
            id = toID(x, y, zoom)
            if not tileHash.get(id):
                tileArray.append([x, y, zoom])


def lineCover(tileHash, coords, maxZoom, ring):
    from numpy import inf

    prevX = None
    prevY = None
    y = None

    coords_length = len(coords)

    for i in range(0, coords_length - 1):
        start = pointToTileFraction(coords[i][0], coords[i][1], maxZoom)
        stop = pointToTileFraction(coords[i + 1][0], coords[i + 1][1], maxZoom)
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
        tMaxX = float('inf') if dx == 0 else abs(((1 if dx > 0 else 0) + x - x0) / dx)
        tMaxY = float('inf') if dy == 0 else abs(((1 if dy > 0 else 0) + y - y0) / dy)
        tdx = float('inf') if dx == 0 else abs(sx / dx)
        tdy = float('inf') if dy == 0 else abs(sy / dy)

        if x != prevX or y != prevY:
            tileHash[toID(x, y, maxZoom)] = True
            if ring is not None and y != prevY:
                ring.append([x, y])
            prevX = x
            prevY = y

        while tMaxX < 1 or tMaxY < 1:
            if tMaxX < tMaxY:
                tMaxX += tdx
                x += sx
            else:
                tMaxY += tdy
                y += sy

            tileHash[toID(x, y, maxZoom)] = True
            if ring is not None and y != prevY:
                ring.append([x, y])
            prevX = x
            prevY = y

    if ring and y == ring[0][1]:
        ring.pop()


def appendHashTiles(hash, tiles):
    keys = list(hash.keys())
    for key in keys:
        tiles.append(fromID(+key))


def toID(x, y, z):
    dim = 2 * (1 << int(z))
    return ((dim * y + x) * 32) + z


def fromID(id):
    z = id % 32
    dim = 2 * (1 << int(z))
    xy = (id - z) / 32
    x = xy % dim
    y = ((xy - x) / dim) % dim
    return [x, y, z]


# Tilebelt
def pointToTileFraction(lon, lat, z):
    sin = math.sin(lat * d2r)
    z2 = math.pow(2, z)
    x = z2 * (lon / 360 + 0.5)
    y = z2 * (0.5 - 0.25 * math.log((1 + sin) / (1 - sin)) / math.pi)

    #  Wrap Tile X
    x = x % z2
    if x < 0:
        x = x + z2
    return [x, y, z]
