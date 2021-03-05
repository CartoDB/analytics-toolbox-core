// -----------------------------------------------------------------------
// --
// -- Copyright (C) 2021 CARTO
// --
// -----------------------------------------------------------------------
/**
 * This code make use of @mapbox/tilebelt and @mapbox/tile-cover
 * whose LICENSE is placed inside the same folder.
 */

const tilebelt = require('@mapbox/tilebelt');
const tilecover = require('@mapbox/tile-cover');

/**
 * convert tile coordinates to quadint at specific zoom level
 * @param  {zxycoord} zxy   zoom and tile coordinates
 * @return {int}            quadint for input tile coordinates at input zoom level
 */
quadintFromZXY = function(z, x, y) {
    if (z < 0 || z > 29) {
        throw new Error('Wrong zoom');
    }
    const zI = z;
    if (zI <= 13) {
        let quadint = y;
        quadint <<= zI;
        quadint |= x;
        quadint <<= 5;
        quadint |= zI;
        return quadint;
    }
    let quadint = BigInt(y);
    quadint <<= BigInt(z);
    quadint |= BigInt(x);
    quadint <<= BigInt(5);
    quadint |= BigInt(z);
    return quadint;
};
module.exports.quadintFromZXY = this.quadintFromZXY;

/**
 * convert quadint to tile coordinates and level of zoom
 * @param  {int} quadint   quadint to be converted
 * @return {zxycoord}      level of zoom and tile coordinates
 */
ZXYFromQuadint = function(quadint) {
    const quadintBig = BigInt(quadint);
    const z = quadintBig & BigInt(0x1F);
    if (z <= 13n) {
        const zNumber = Number(z);
        const x = (quadint >> 5) & ((1 << zNumber) - 1);
        const y = quadint >> (zNumber + 5);
        return { z: zNumber, x: x, y: y };
    }
    const x = (quadintBig >> (5n)) & ((1n << z) - 1n);
    const y = quadintBig >> (5n + z);
    return { z: Number(z), x: Number(x), y: Number(y) };
};
module.exports.ZXYFromQuadint = this.ZXYFromQuadint;

/**
 * get quadint for location at specific zoom level
 * @param  {geocoord} location  location coordinates to convert to quadint
 * @param  {number}   zoom      map zoom level of quadint to return
 * @return {string}             quadint the input location resides in for the input zoom level
 */
quadintFromLocation = function(long, lat, zoom) {
    if (zoom < 0 || zoom > 29) {
        throw new Error('Wrong zoom');
    }
    const tile = tilebelt.pointToTile(long, lat, zoom - 1);
    return quadintFromZXY(zoom, tile[0], tile[1]);
};
module.exports.quadintFromLocation = this.quadintFromLocation;

/**
 * convert quadkey into a quadint
 * @param  {string} quadkey     quadkey to be converted
 * @return {int}                quadint
 */
quadintFromQuadkey = function(quadkey) {
    const z = quadkey.length;
    const tile = tilebelt.quadkeyToTile(quadkey);
    return quadintFromZXY(z, tile[0], tile[1]);
};
module.exports.quadintFromQuadkey = this.quadintFromQuadkey;

/**
 * convert quadint into a quadkey
 * @param  {int} quadint    quadint to be converted
 * @return {string}         quadkey
 */
quadkeyFromQuadint = function(quadint) {
    const tile = ZXYFromQuadint(quadint);
    return tilebelt.tileToQuadkey([tile.x, tile.y, tile.z]);
};
module.exports.quadkeyFromQuadint = this.quadkeyFromQuadint;

/**
 * get the bounding box for a quadint in location coordinates
 * @param  {int} quadint    quadint to get bounding box from
 * @return {bbox}           bounding box for the input quadint
 */
bbox = function(quadint) {
    const tile = ZXYFromQuadint(quadint);
    return tilebelt.tileToBBOX([tile.x, tile.y, tile.z]);
};
module.exports.bbox = this.bbox;

/**
 * get the GeoJSON with the bounding box for a quadint in location coordinates
 * @param  {int} quadint    quadint to get bounding box from
 * @return {GeoJSON}        GeoJSON with the bounding box for the input quadint
 */
quadintToGeoJSON = function(quadint) {
    const tile = ZXYFromQuadint(quadint);
    return tilebelt.tileToGeoJSON([tile.x, tile.y, tile.z]);
};
module.exports.quadintToGeoJSON = this.quadintToGeoJSON;

/**
 * returns the sibling of the given quadint and will wrap
 * @param  {int} quadint      key to get sibling of
 * @param  {string} direction direction of sibling from key
 * @return {int}              sibling key
 */
sibling = function(quadint, direction) {
    direction = direction.toLowerCase();
    if (direction !== 'left' && direction !== 'right' && direction !== 'up' && direction !== 'down') {
        throw new Error('Wrong direction argument passed to sibling');
    }

    const tile = ZXYFromQuadint(quadint);
    const z = tile.z;
    let x = tile.x;
    let y = tile.y;
    const tilesPerLevel = 2 << (z - 1);
    if (direction === 'left') {
        x = x > 0 ? x - 1 : tilesPerLevel - 1;
    }
    if (direction === 'right') {
        x = x < tilesPerLevel - 1 ? x + 1 : 0;
    }
    if (direction === 'up') {
        y = y > 0 ? y - 1 : tilesPerLevel - 1;
    }
    if (direction === 'down') {
        y = y < tilesPerLevel - 1 ? y + 1 : 0;
    }
    return quadintFromZXY(z, x, y);
};
module.exports.sibling = this.sibling;

/**
 * get all the children quadints of a quadint
 * @param  {int} quadint    quadint to get the children of
 * @return {array}          array of quadints representing the children of the input quadint
 */
children = function(quadint) {
    const zxy = ZXYFromQuadint(quadint);
    if (zxy.z < 0 || zxy.z > 28) {
        throw new Error('Wrong zoom');
    }
    const z = zxy.z + 1;
    const x = zxy.x << 1;
    const y = zxy.y << 1;
    return [quadintFromZXY(z, x, y), quadintFromZXY(z, x + 1, y),
        quadintFromZXY(z, x, y + 1), quadintFromZXY(z, x + 1, y + 1)];
};
module.exports.children = this.children;

/**
 * get the parent of a quadint
 * @param  {int} quadint quadint to get the parent of
 * @return {int}         parent of the input quadint
 */
parent = function(quadint) {
    const zxy = ZXYFromQuadint(quadint);
    if (zxy.z < 1 || zxy.z > 29) {
        throw new Error('Wrong zoom');
    }
    return quadintFromZXY(zxy.z - 1, zxy.x >> 1, zxy.y >> 1);
};
module.exports.parent = this.parent;

/**
 * get an array of quadints containing a geography for given zooms
 * @param  {object} poly    geography we want to extract the quadints from
 * @param  {struct} limits  struct containing the range of zooms
 * @return {array}          array of quadints containing a geography
 */
geojsonToQuadints = function(poly, limits) {
    return tilecover.indexes(poly, limits).map(quadintFromQuadkey);
};
module.exports.geojsonToQuadints = this.geojsonToQuadints;
