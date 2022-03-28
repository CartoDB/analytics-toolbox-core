// ----------------------------
// -- Copyright (C) 2021 CARTO
// ----------------------------

import tilebelt from '@mapbox/tilebelt';
import tilecover from '@mapbox/tile-cover';

/**
 * convert tile coordinates to quadint at specific zoom level
 * @param  {zxycoord} zxy   zoom and tile coordinates
 * @return {BigInt}            quadint for input tile coordinates at input zoom level
 */
export function quadintFromZXY(z, x, y) {
    if (z < 0 || z > 29) {
        throw new Error('Wrong zoom');
    }
    const useBigInt = z > 13;
    const B = [0x5555555555555555n, 0x3333333333333333n, 0x0F0F0F0F0F0F0F0Fn, 0x00FF00FF00FF00FFn, 0x0000FFFF0000FFFFn];
    const S = [1n, 2n, 4n, 8n, 16n];
    x = BigInt(x);
    y = BigInt(y);
    z = BigInt(z);
    x = (x | (x << S[4])) & B[4];
    y = (y | (y << S[4])) & B[4];

    x = (x | (x << S[3])) & B[3];
    y = (y | (y << S[3])) & B[3];

    x = (x | (x << S[2])) & B[2];
    y = (y | (y << S[2])) & B[2];

    x = (x | (x << S[1])) & B[1];
    y = (y | (y << S[1])) & B[1];

    x = (x | (x << S[0])) & B[0];
    y = (y | (y << S[0])) & B[0];
    let quadint = x | (y << 1n);
    quadint <<= 5n;
    quadint |= z;
    return quadint;
}

/**
 * convert quadint to tile coordinates and level of zoom
 * @param  {int|BigInt} quadint   quadint to be converted
 * @return {zxycoord}      level of zoom and tile coordinates
 */
export function ZXYFromQuadint(quadint) {
    const B = [0x5555555555555555n, 0x3333333333333333n, 0x0F0F0F0F0F0F0F0Fn, 0x00FF00FF00FF00FFn, 0x0000FFFF0000FFFFn,
        0x00000000FFFFFFFFn];
    const S = [0n, 1n, 2n, 4n, 8n, 16n];
    quadint = BigInt(quadint);
    const z = quadint & 0x1Fn;
    quadint >>= 5n;
    let x = quadint;
    let y = quadint >> 1n;

    x = (x | (x >> S[0])) & B[0];
    y = (y | (y >> S[0])) & B[0];

    x = (x | (x >> S[1])) & B[1];
    y = (y | (y >> S[1])) & B[1];

    x = (x | (x >> S[2])) & B[2];
    y = (y | (y >> S[2])) & B[2];

    x = (x | (x >> S[3])) & B[3];
    y = (y | (y >> S[3])) & B[3];

    x = (x | (x >> S[4])) & B[4];
    y = (y | (y >> S[4])) & B[4];

    x = (x | (x >> S[5])) & B[5];
    y = (y | (y >> S[5])) & B[5];

    return {x: Number(x), y: Number(y), z: Number(z)};
}

/**
 * get quadint for location at specific zoom level
 * @param  {geocoord} location  location coordinates to convert to quadint
 * @param  {number}   zoom      map zoom level of quadint to return
 * @return {string}             quadint the input location resides in for the input zoom level
 */
export function quadintFromLocation (long, lat, zoom) {
    if (zoom < 0 || zoom > 29) {
        throw new Error('Wrong zoom');
    }
    lat = clipNumber(lat, -85.05, 85.05);
    const tile = tilebelt.pointToTile(long, lat, zoom);
    return quadintFromZXY(zoom, tile[0], tile[1]);
}

/**
 * convert quadkey into a quadint
 * @param  {string} quadkey     quadkey to be converted
 * @return {int}                quadint
 */
export function quadintFromQuadkey (quadkey) {
    const z = quadkey.length;
    const tile = tilebelt.quadkeyToTile(quadkey);
    return quadintFromZXY(z, tile[0], tile[1]);
}

/**
 * convert quadint into a quadkey
 * @param  {int} quadint    quadint to be converted
 * @return {string}         quadkey
 */
export function quadkeyFromQuadint (quadint) {
    const tile = ZXYFromQuadint(quadint);
    return tilebelt.tileToQuadkey([tile.x, tile.y, tile.z]);
}

/**
 * get the bounding box for a quadint in location coordinates
 * @param  {int} quadint    quadint to get bounding box from
 * @return {bbox}           bounding box for the input quadint
 */
export function bbox (quadint) {
    const tile = ZXYFromQuadint(quadint);
    return tilebelt.tileToBBOX([tile.x, tile.y, tile.z]);
}

/**
 * get the GeoJSON with the bounding box for a quadint in location coordinates
 * @param  {int} quadint    quadint to get bounding box from
 * @return {GeoJSON}        GeoJSON with the bounding box for the input quadint
 */
export function quadintToGeoJSON (quadint) {
    const tile = ZXYFromQuadint(quadint);
    return tilebelt.tileToGeoJSON([tile.x, tile.y, tile.z]);
}

/**
 * returns the sibling of the given quadint and will wrap
 * @param  {int} quadint      key to get sibling of
 * @param  {string} direction direction of sibling from key
 * @return {int}              sibling key
 */
export function sibling (quadint, direction) {
    direction = direction.toLowerCase();
    if (direction !== 'left' && direction !== 'right' && direction !== 'up' && direction !== 'down') {
        throw new Error('Wrong direction argument passed to sibling');
    }
    if (direction === 'left') {
        return siblingLeft(quadint);
    }
    if (direction === 'right') {
        return siblingRight(quadint);
    }
    if (direction === 'up') {
        return siblingUp(quadint);
    }
    if (direction === 'down') {
        return siblingDown(quadint);
    }
}

/**
 * returns the sibling of the given quadint and will wrap
 * @param  {int} quadint      key to get sibling of
 * @param  {string} direction direction of sibling from key
 * @return {int}              sibling key
 */
export function siblingLeft (quadint) {
    const tile = ZXYFromQuadint(quadint);
    const tilesPerLevel = 2 << (tile.z - 1);
    const x = tile.x > 0 ? tile.x - 1 : tilesPerLevel - 1;
    return quadintFromZXY(tile.z, x, tile.y);
}

/**
 * returns the sibling of the given quadint and will wrap
 * @param  {int} quadint      key to get sibling of
 * @param  {string} direction direction of sibling from key
 * @return {int}              sibling key
 */
export function siblingRight (quadint) {
    const tile = ZXYFromQuadint(quadint);
    const tilesPerLevel = 2 << (tile.z - 1);
    const x = tile.x < tilesPerLevel - 1 ? tile.x + 1 : 0;
    return quadintFromZXY(tile.z, x, tile.y);
}

/**
 * returns the sibling of the given quadint and will wrap
 * @param  {int} quadint      key to get sibling of
 * @param  {string} direction direction of sibling from key
 * @return {int}              sibling key
 */
export function siblingUp (quadint) {
    const tile = ZXYFromQuadint(quadint);
    const tilesPerLevel = 2 << (tile.z - 1);
    const y = tile.y > 0 ? tile.y - 1 : tilesPerLevel - 1;
    return quadintFromZXY(tile.z, tile.x, y);
}

/**
 * returns the sibling of the given quadint and will wrap
 * @param  {int} quadint      key to get sibling of
 * @param  {string} direction direction of sibling from key
 * @return {int}              sibling key
 */
export function siblingDown (quadint) {
    const tile = ZXYFromQuadint(quadint);
    const tilesPerLevel = 2 << (tile.z - 1);
    const y = tile.y < tilesPerLevel - 1 ? tile.y + 1 : 0;
    return quadintFromZXY(tile.z, tile.x, y);
}

/**
 * get all the children quadints of a quadint
 * @param  {int} quadint    quadint to get the children of
 * @param  {int} resolution resolution of the desired children
 * @return {array}          array of quadints representing the children of the input quadint
 */
export function toChildren (quadint, resolution) {
    const zxy = ZXYFromQuadint(quadint);
    if (zxy.z < 0 || zxy.z > 28) {
        throw new Error('Wrong quadint zoom');
    }

    if (resolution < 0 || resolution <= zxy.z) {
        throw new Error('Wrong resolution');
    }
    const diffZ = resolution - zxy.z;
    const mask = (1 << diffZ) - 1;
    const minTileX = zxy.x << diffZ;
    const maxTileX = minTileX | mask;
    const minTileY = zxy.y << diffZ;
    const maxTileY = minTileY | mask;
    const children = [];
    let x, y;
    for (x = minTileX; x <= maxTileX; x++) {
        for (y = minTileY; y <= maxTileY; y++) {
            children.push(quadintFromZXY(resolution, x, y));
        }
    }
    return children;
}

/**
 * get the parent of a quadint
 * @param  {int} quadint quadint to get the parent of
 * @param  {int} resolution resolution of the desired parent
 * @return {int}         parent of the input quadint
 */
export function toParent (quadint, resolution) {
    const zxy = ZXYFromQuadint(quadint);
    if (zxy.z < 1 || zxy.z > 29) {
        throw new Error('Wrong quadint zoom');
    }
    if (resolution < 0 || resolution >= zxy.z) {
        throw new Error('Wrong resolution');
    }
    return quadintFromZXY(resolution, zxy.x >> (zxy.z - resolution), zxy.y >> (zxy.z - resolution));
}

/**
 * get the kring of a quadint
 * @param  {int} origin quadint to get the kring of
 * @param  {int} size in tiles of the desired kring
 * @return {int}         kring of the input quadint
 */
export function kRing (origin, size) {
    if (size === 0) {
        return [origin.toString()];
    }

    let i, j;
    let cornerQuadint = origin;
    // Traverse to top left corner
    for (i = 0; i < size; i++) {
        cornerQuadint = siblingLeft(cornerQuadint);
        cornerQuadint = siblingUp(cornerQuadint)
    }

    const neighbors = [];
    let traversalQuadint;
    for (j = 0; j < size * 2 + 1; j++) {
        traversalQuadint = cornerQuadint;
        for (i = 0; i < size * 2 + 1; i++) {
            neighbors.push(traversalQuadint.toString());
            traversalQuadint = siblingRight(traversalQuadint);
        }
        cornerQuadint = siblingDown(cornerQuadint)
    }
    return neighbors;
}

/**
 * get the kring distances of a quadint
 * @param  {int} origin quadint to get the kring of
 * @param  {int} size in tiles of the desired kring
 * @return {int}         kring distances of the input quadint
 */
export function kRingDistances (origin, size) {
    if (size === 0) {
        return [{ index: origin.toString(), distance: 0 }];
    }

    let cornerQuadint = origin;
    // Traverse to top left corner
    for (let i = 0; i < size; i++) {
        cornerQuadint = siblingLeft(cornerQuadint);
        cornerQuadint = siblingUp(cornerQuadint)
    }

    const neighbors = [];
    let traversalQuadint;
    for (let j = -size; j <= size; j++) {
        traversalQuadint = cornerQuadint;
        for (let i = -size; i <= size; i++) {
            neighbors.push({
                index: traversalQuadint.toString(),
                distance: Math.max(Math.abs(i), Math.abs(j)) // Chebychev distance
            });
            traversalQuadint = siblingRight(traversalQuadint);
        }
        cornerQuadint = siblingDown(cornerQuadint)
    }
    return neighbors.sort((a, b) => (a['distance'] > b['distance']) ? 1 : -1);
}

/**
 * get an array of quadints containing a geography for given zooms
 * @param  {object} poly    geography we want to extract the quadints from
 * @param  {struct} limits  struct containing the range of zooms
 * @return {array}          array of quadints containing a geography
 */
export function geojsonToQuadints (poly, limits) {
    return tilecover.tiles(poly, limits).map(tile => quadintFromZXY(tile[2], tile[0], tile[1]));
}

const clipNumber = (num, a, b) => Math.max(Math.min(num, Math.max(a, b)), Math.min(a, b));