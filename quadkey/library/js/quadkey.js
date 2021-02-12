/**
 * @typedef xycoord
 * @type {object}
 * @property {number} x x coordinate
 * @property {number} y y coordinate
 */

/**
 * @typedef geocoord
 * @type {object}
 * @property {number} lat latitude
 * @property {number} lng longitude
 */

/**
 * @typedef bbox
 * @type {object}
 * @property {geocoord} min minimum coordinates for the bounding box
 * @property {geocoord} max maximum coordinates for the bounding box
 */

const EarthRadius = 6378137.0;
const MinLatitude = -85.05112878;
const MaxLatitude = 85.05112878;
const MinLongitude = -180.0;
const MaxLongitude = 180.0;

const Direction = Object.freeze({
    Up: 0,
    Down: 1,
    Left: 2,
    Right: 3
});

/**
 * clips a number by a minimum and maximum value
 * @param  {number} n        the number to clip
 * @param  {number} minValue minimum value, if n is less this will return
 * @param  {number} maxValue maximum value, if n is greater than this will return
 * @return {number}          value of n clipped to be >= minValue and <= maxValue
 */
function clip(n, minValue, maxValue) {
    return Math.min(Math.max(n, minValue), maxValue);
}

/**
 * get tile coordinates for location at specific detail level
 * @param  {geocoord} location location coordinates to convert to tile
 * @param  {number}   detail   map detail level of tile to return
 * @return {xycoord}           tile coordinates
 */
locationToTile = function(location, detail) {
    const worldLimitHalf = EarthRadius * Math.PI;
    const worldRange = worldLimitHalf * 2;
    const radiansOverDegrees = Math.PI / 180.0;

    const xTransform = x => worldLimitHalf + (x * worldRange) / 360;
    const yTransform = y => {
        y *= radiansOverDegrees;
        y = Math.log(Math.tan(y) + (1.0 / Math.cos(y)));
        return worldLimitHalf - (y * EarthRadius);
    };

    const longitude = clip(location.lng, MinLongitude, MaxLongitude);
    const latitude = clip(location.lat, MinLatitude, MaxLatitude);

    const zoomDivisor = worldRange / Math.pow(2, detail);
    const maxTile = Math.pow(2, detail) - 1;

    const x = Math.min(maxTile, Math.floor((xTransform(longitude)) / zoomDivisor));
    const y = Math.min(maxTile, Math.floor((yTransform(latitude)) / zoomDivisor));

    return { x, y };
};

/**
 * convert tile coordinates to quadkey at specific detail level
 * @param  {xycoord} tile   tile coordinates
 * @param  {number}  detail map detail level to use for conversion
 * @return {string}         quadkey for input tile coordinates at input detail level
 */
tileToQuadkey = function(tile, detail) {
    const maxIntBits = 31;
    let out = '';
    let x, y, mask, shiftValue;

    if (detail >= maxIntBits) {
        /* Since BigInt operations are 10x slower, only use them when strictly necessary */
        x = BigInt(tile.x);
        y = BigInt(tile.y);
        mask = BigInt(1) << (BigInt(detail - 1));
        shiftValue = BigInt(1);

        for (let i = detail; i > maxIntBits; i--, mask = mask >> shiftValue) {
            let value = '0'.charCodeAt(0);
            value += 1 * ((x & mask) !== 0);
            value += 2 * ((y & mask) !== 0);
            out += String.fromCharCode(value);
        }
    }

    const secondLoopStart = Math.min(maxIntBits, detail);
    x = tile.x & 0xFFFFFFFF;
    y = tile.y & 0xFFFFFFFF;
    mask = 1 << (secondLoopStart - 1);
    shiftValue = 1;

    for (let i = secondLoopStart; i > 0; i--, mask = mask >> 1) {
        let value = '0'.charCodeAt(0);
        value += 1 * ((x & mask) !== 0);
        value += 2 * ((y & mask) !== 0);
        out += String.fromCharCode(value);
    }

    return out;
};

/**
 * convert quadkey to tile coordinates, detail level can be inferred from the length of
 * the quadkey string.
 * @param  {string}  quadkey quadkey to be converted
 * @return {xycoord}         tile coordinates
 */
quadkeyToTile = function(quadkey) {
    const maxIntBits = 31;
    const detail = quadkey.length;
    let tileX = 0;
    let tileY = 0;

    if (detail >= maxIntBits) {
        let mask = Math.pow(2, detail - 1);
        for (let i = detail; i > 0; i--, mask = Math.floor(mask / 2)) {
            const index = detail - i;
            switch (quadkey[index]) {
            case '0':
                continue;
            case '1':
                tileX += mask;
                break;
            case '2':
                tileY += mask;
                break;
            case '3':
                tileX += mask;
                tileY += mask;
                break;
            default:
                break;
            }
        }
    } else {
        let mask = 1 << (detail - 1);
        for (let i = detail; i > 0; i--, mask >>= 1) {
            const index = detail - i;
            switch (quadkey[index]) {
            case '0':
                continue;
            case '1':
                tileX += mask;
                break;
            case '2':
                tileY += mask;
                break;
            case '3':
                tileX += mask;
                tileY += mask;
                break;
            default:
                break;
            }
        }
    }
    return {
        x: tileX,
        y: tileY
    };
};

/**
 * convert tile coordinates to quadint at specific detail level
 * @param  {zxycoord} zxy  detail and tile coordinates
 * @return {int}    quadint for input tile coordinates at input detail level
 */
quadintFromZXY = function(z, x, y) {
    const zI = parseInt(z);
    if (zI <= 13) {
        let quadint = parseInt(y);
        quadint <<= zI;
        quadint |= parseInt(x);
        quadint <<= 5;
        quadint |= zI;
        return quadint;
    }
    let quadint = BigInt(y);
    quadint <<= BigInt(z);
    quadint |= BigInt(x);
    quadint <<= BigInt(5);
    quadint |= BigInt(z);
    return quadint.toString();
};

/**
 * convert quadint to tile coordinates and level of detail
 * @param  {int}  quadint quadint to be converted
 * @return {zxycoord}      level of detail and tile coordinates
 */
ZXYFromQuadint = function(quadint) {
    const quadintBig = BigInt(quadint);
    const z = quadintBig & BigInt(0x1F);
    if (z <= 13n) {
        const quadintNumber = Number(quadint);
        const zNumber = Number(z);
        const x = (quadintNumber >> 5) & ((1 << zNumber) - 1);
        const y = quadintNumber >> (zNumber + 5);
        return { z: zNumber.toString(), x: x.toString(), y: y.toString() };
    }
    const x = (quadintBig >> (5n)) & ((1n << z) - 1n);
    const y = quadintBig >> (5n + z);
    return { z: z.toString(), x: x.toString(), y: y.toString() };
};

/**
 * get quadint for location at specific detail level
 * @param  {geocoord} location location coordinates to convert to quadint
 * @param  {number}   detail   map detail level of quadint to return
 * @return {string}            quadint the input location resides in for the input detail level
 */
quadintFromLocation = function(location, detail) {
    const tile = locationToTile(location, detail);
    return quadintFromZXY(detail, tile.x, tile.y);
};

/**
 * convert quadkey into a quadint
 * @param  {string}  quadkey quadkey to be converted
 * @return {int}   quadint
 */
quadintFromQuadkey = function(quadkey) {
    const z = quadkey.length;
    const tile = quadkeyToTile(quadkey);
    return quadintFromZXY(z, tile.x, tile.y);
};

/**
 * convert quadint into a quadkey
 * @param  {int}  quadint quadint to be converted
 * @return {string}      quadkey
 */
quadkeyFromQuadint = function(quadint) {
    const tile = ZXYFromQuadint(quadint);
    return tileToQuadkey({ x: parseInt(tile.x), y: parseInt(tile.y) }, parseInt(tile.z));
};

/**
 * Transforms coordinates from 3857 to 4326
 * @param  {number} x Point longitude in 3857
 * @param  {number} y Point latitude in 3857
 * @return {geocoord}       location coordinates in 4326
 */
coords3857ToLongLat = function(x, y) {
    const worldLimitHalf = EarthRadius * Math.PI;

    /* TODO: When we have a CI, we should test this. A quadkey that used to go slightly over the
    * antimeridian was 311131313 */
    const lng = Math.min(((x * 180.0) / worldLimitHalf), MaxLongitude);
    const lat = -90 + 360.0 * Math.atan(Math.exp(Math.PI * (y / worldLimitHalf))) / Math.PI;
    return { lng, lat };
};

/**
 * get the bounding box for a quadint in location coordinates
 * @param  {int} quadint quadint to get bounding box of
 * @return {bbox}           bounding box for the input quadint
 */
bbox = function(quadint) {
    const worldLimitHalf = EarthRadius * Math.PI;
    const worldRange = worldLimitHalf * 2;

    const tile = ZXYFromQuadint(quadint);
    const z = parseInt(tile.z);
    const tileSize = worldRange / Math.pow(2, z);

    const xLeft = -worldLimitHalf + parseInt(tile.x) * tileSize;
    const yBottom = worldLimitHalf - (parseInt(tile.y) + 1) * tileSize;
    const minCoord = coords3857ToLongLat(xLeft, yBottom);
    const maxCoord = coords3857ToLongLat(xLeft + tileSize, yBottom + tileSize);

    return {
        min: minCoord,
        max: maxCoord
    };
};

/**
 * determine if a location is inside a quadint
 * @param  {geocoord} location location to check if inside quadint
 * @param  {int}   quadint  quadint to check if location is inside it
 * @return {boolean}           true if location is inside quadint and false otherwise
 */
inside = function(location, quadint) {
    const tile = ZXYFromQuadint(quadint);
    return quadint === quadintFromLocation(location, parseInt(tile.z));
};

/**
 * get the center origin location of a quadint
 * @param  {int}   quadint quadint to get the center origin location of
 * @return {geocoord}         location coordinates of teh center origin of the input quadint
 */
origin = function(quadint) {
    const bboxCoords = bbox(quadint);
    const centerLat = (bboxCoords.min.lat + bboxCoords.max.lat) / 2.0;
    const centerLng = (bboxCoords.min.lng + bboxCoords.max.lng) / 2.0;
    return {
        lat: centerLat,
        lng: centerLng
    };
};

/**
 * returns the sibling of the given quadint and will wrap
 * @param  {int} quadint      key to get sibling of
 * @param  {Direction} direction direction of sibling from key
 * @return {int}              sibling key
 */
sibling = function(quadint, direction) {
    direction = {
        left: Direction.Left,
        right: Direction.Right,
        up: Direction.Up,
        down: Direction.Down
    }[direction];
    const tile = ZXYFromQuadint(quadint);
    const z = parseInt(tile.z);
    let x = parseInt(tile.x);
    let y = parseInt(tile.y);
    const tilesPerLevel = 2 << (z - 1);
    if (direction === Direction.Left) {
        x = x > 0 ? x - 1 : tilesPerLevel - 1;
    }
    if (direction === Direction.Right) {
        x = x < tilesPerLevel - 1 ? x + 1 : 0;
    }
    if (direction === Direction.Up) {
        y = y > 0 ? y - 1 : tilesPerLevel - 1;
    }
    if (direction === Direction.Down) {
        y = y < tilesPerLevel - 1 ? y + 1 : 0;
    }
    return quadintFromZXY(z, x, y);
};

/**
 * get all the children quadints of a quadint
 * @param  {int} quadint quadint to get the children of
 * @return {array}          array of quadints representing the children of the input quadint
 */
children = function(quadint) {
    const zxy = ZXYFromQuadint(quadint);
    const z = parseInt(zxy.z) + 1;
    const x = parseInt(zxy.x) << 1;
    const y = parseInt(zxy.y) << 1;
    return [quadintFromZXY(z, x, y), quadintFromZXY(z, x + 1, y),
        quadintFromZXY(z, x, y + 1), quadintFromZXY(z, x + 1, y + 1)];
};

/**
 * get the parent of a quadint
 * @param  {int} quadint quadint to get the parent of
 * @return {int}         parent of the input quadint
 */
parent = function(quadint) {
    const zxy = ZXYFromQuadint(quadint);
    return quadintFromZXY(parseInt(zxy.z) - 1, parseInt(zxy.x) >> 1, parseInt(zxy.y) >> 1);
};
