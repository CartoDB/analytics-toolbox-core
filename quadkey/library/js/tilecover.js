(function() {
    function r(e, n, t) {
        function o(i, f) {
            if (!n[i]) {
                if (!e[i]) {
                    const c = typeof require === 'function' && require; if (!f && c) return c(i, !0); if (u) return u(i, !0); const a = new Error("Cannot find module '" + i + "'"); throw a;
                } const p = n[i] = { exports: {} }; e[i][0].call(p.exports, function(r) {
                    const n = e[i][1][r]; return o(n || r);
                }, p, p.exports, r, e, n, t);
            } return n[i].exports;
        } for (typeof require === 'function' && require, i = 0; i < t.length; i++)o(t[i]); return o;
    } return r;
})()({
    1: [function(require, module, exports) {
        'use strict';

        const tilebelt = require('@mapbox/tilebelt');

        /**
 * Given a geometry, create cells and return them in a format easily readable
 * by any software that reads GeoJSON.
 *
 * @alias geojson
 * @param {Object} geom GeoJSON geometry
 * @param {Object} limits an object with min_zoom and max_zoom properties
 * specifying the minimum and maximum level to be tiled.
 * @returns {Object} FeatureCollection of cells formatted as GeoJSON Features
 */
        exports.geojson = function(geom, limits) {
            return {
                type: 'FeatureCollection',
                features: getTiles(geom, limits).map(tileToFeature)
            };
        };

        function tileToFeature(t) {
            return {
                type: 'Feature',
                geometry: tilebelt.tileToGeoJSON(t),
                properties: {}
            };
        }

        /**
 * Given a geometry, create cells and return them in their raw form,
 * as an array of cell identifiers.
 *
 * @alias tiles
 * @param {Object} geom GeoJSON geometry
 * @param {Object} limits an object with min_zoom and max_zoom properties
 * specifying the minimum and maximum level to be tiled.
 * @returns {Array<Array<number>>} An array of tiles given as [x, y, z] arrays
 */
        exports.tiles = getTiles;

        /**
 * Given a geometry, create cells and return them as
 * [quadkey](http://msdn.microsoft.com/en-us/library/bb259689.aspx) indexes.
 *
 * @alias indexes
 * @param {Object} geom GeoJSON geometry
 * @param {Object} limits an object with min_zoom and max_zoom properties
 * specifying the minimum and maximum level to be tiled.
 * @returns {Array<String>} An array of tiles given as quadkeys.
 */
        exports.indexes = function(geom, limits) {
            return getTiles(geom, limits).map(tilebelt.tileToQuadkey);
        };

        function getTiles(geom, limits) {
            let i; let tile;
            const coords = geom.coordinates;
            const maxZoom = limits.max_zoom;
            const tileHash = {};
            const tiles = [];

            if (geom.type === 'Point') {
                return [tilebelt.pointToTile(coords[0], coords[1], maxZoom)];
            } else if (geom.type === 'MultiPoint') {
                for (i = 0; i < coords.length; i++) {
                    tile = tilebelt.pointToTile(coords[i][0], coords[i][1], maxZoom);
                    tileHash[toID(tile[0], tile[1], tile[2])] = true;
                }
            } else if (geom.type === 'LineString') {
                lineCover(tileHash, coords, maxZoom);
            } else if (geom.type === 'MultiLineString') {
                for (i = 0; i < coords.length; i++) {
                    lineCover(tileHash, coords[i], maxZoom);
                }
            } else if (geom.type === 'Polygon') {
                polygonCover(tileHash, tiles, coords, maxZoom);
            } else if (geom.type === 'MultiPolygon') {
                for (i = 0; i < coords.length; i++) {
                    polygonCover(tileHash, tiles, coords[i], maxZoom);
                }
            } else {
                throw new Error('Geometry type not implemented');
            }

            if (limits.min_zoom !== maxZoom) {
                // sync tile hash and tile array so that both contain the same tiles
                const len = tiles.length;
                appendHashTiles(tileHash, tiles);
                for (i = 0; i < len; i++) {
                    const t = tiles[i];
                    tileHash[toID(t[0], t[1], t[2])] = true;
                }
                return mergeTiles(tileHash, tiles, limits);
            }

            appendHashTiles(tileHash, tiles);
            return tiles;
        }

        function mergeTiles(tileHash, tiles, limits) {
            const mergedTiles = [];

            for (let z = limits.max_zoom; z > limits.min_zoom; z--) {
                const parentTileHash = {};
                const parentTiles = [];
                let i, t;
                for (i = 0; i < tiles.length; i++) {
                    t = tiles[i];

                    if (t[0] % 2 === 0 && t[1] % 2 === 0) {
                        const id2 = toID(t[0] + 1, t[1], z);
                        const id3 = toID(t[0], t[1] + 1, z);
                        const id4 = toID(t[0] + 1, t[1] + 1, z);

                        if (tileHash[id2] && tileHash[id3] && tileHash[id4]) {
                            tileHash[toID(t[0], t[1], t[2])] = false;
                            tileHash[id2] = false;
                            tileHash[id3] = false;
                            tileHash[id4] = false;

                            const parentTile = [t[0] / 2, t[1] / 2, z - 1];

                            if (z - 1 === limits.min_zoom) mergedTiles.push(parentTile);
                            else {
                                parentTileHash[toID(t[0] / 2, t[1] / 2, z - 1)] = true;
                                parentTiles.push(parentTile);
                            }
                        }
                    }
                }

                for (i = 0; i < tiles.length; i++) {
                    t = tiles[i];
                    if (tileHash[toID(t[0], t[1], t[2])]) mergedTiles.push(t);
                }

                tileHash = parentTileHash;
                tiles = parentTiles;
            }

            return mergedTiles;
        }

        function polygonCover(tileHash, tileArray, geom, zoom) {
            const intersections = [];
            let i;
            let y;
            for (i = 0; i < geom.length; i++) {
                const ring = [];
                lineCover(tileHash, geom[i], zoom, ring);

                for (let j = 0, len = ring.length, k = len - 1; j < len; k = j++) {
                    const m = (j + 1) % len;
                    y = ring[j][1];

                    // add interesction if it's not local extremum or duplicate
                    if ((y > ring[k][1] || y > ring[m][1]) && // not local minimum
                (y < ring[k][1] || y < ring[m][1]) && // not local maximum
                y !== ring[m][1]) intersections.push(ring[j]);
                }
            }

            intersections.sort(compareTiles); // sort by y, then x

            for (i = 0; i < intersections.length; i += 2) {
                // fill tiles between pairs of intersections
                y = intersections[i][1];
                for (let x = intersections[i][0] + 1; x < intersections[i + 1][0]; x++) {
                    const id = toID(x, y, zoom);
                    if (!tileHash[id]) {
                        tileArray.push([x, y, zoom]);
                    }
                }
            }
        }

        function compareTiles(a, b) {
            return (a[1] - b[1]) || (a[0] - b[0]);
        }

        function lineCover(tileHash, coords, maxZoom, ring) {
            let prevX, prevY, y;

            for (let i = 0; i < coords.length - 1; i++) {
                const start = tilebelt.pointToTileFraction(coords[i][0], coords[i][1], maxZoom);
                const stop = tilebelt.pointToTileFraction(coords[i + 1][0], coords[i + 1][1], maxZoom);
                const x0 = start[0];
                const y0 = start[1];
                const x1 = stop[0];
                const y1 = stop[1];
                const dx = x1 - x0;
                const dy = y1 - y0;

                if (dy === 0 && dx === 0) continue;

                const sx = dx > 0 ? 1 : -1;
                const sy = dy > 0 ? 1 : -1;
                let x = Math.floor(x0);
                y = Math.floor(y0);
                let tMaxX = dx === 0 ? Infinity : Math.abs(((dx > 0 ? 1 : 0) + x - x0) / dx);
                let tMaxY = dy === 0 ? Infinity : Math.abs(((dy > 0 ? 1 : 0) + y - y0) / dy);
                const tdx = Math.abs(sx / dx);
                const tdy = Math.abs(sy / dy);

                if (x !== prevX || y !== prevY) {
                    tileHash[toID(x, y, maxZoom)] = true;
                    if (ring && y !== prevY) ring.push([x, y]);
                    prevX = x;
                    prevY = y;
                }

                while (tMaxX < 1 || tMaxY < 1) {
                    if (tMaxX < tMaxY) {
                        tMaxX += tdx;
                        x += sx;
                    } else {
                        tMaxY += tdy;
                        y += sy;
                    }
                    tileHash[toID(x, y, maxZoom)] = true;
                    if (ring && y !== prevY) ring.push([x, y]);
                    prevX = x;
                    prevY = y;
                }
            }

            if (ring && y === ring[0][1]) ring.pop();
        }

        function appendHashTiles(hash, tiles) {
            const keys = Object.keys(hash);
            for (let i = 0; i < keys.length; i++) {
                tiles.push(fromID(+keys[i]));
            }
        }

        function toID(x, y, z) {
            const dim = 2 * (1 << z);
            return ((dim * y + x) * 32) + z;
        }

        function fromID(id) {
            const z = id % 32;
            const dim = 2 * (1 << z);
            const xy = ((id - z) / 32);
            const x = xy % dim;
            const y = ((xy - x) / dim) % dim;
            return [x, y, z];
        }
    }, { '@mapbox/tilebelt': 2 }],
    2: [function(require, module, exports) {
        'use strict';

        const d2r = Math.PI / 180;
        const r2d = 180 / Math.PI;

        /**
 * Get the bbox of a tile
 *
 * @name tileToBBOX
 * @param {Array<number>} tile
 * @returns {Array<number>} bbox
 * @example
 * var bbox = tileToBBOX([5, 10, 10])
 * //=bbox
 */
        function tileToBBOX(tile) {
            const e = tile2lon(tile[0] + 1, tile[2]);
            const w = tile2lon(tile[0], tile[2]);
            const s = tile2lat(tile[1] + 1, tile[2]);
            const n = tile2lat(tile[1], tile[2]);
            return [w, s, e, n];
        }

        /**
 * Get a geojson representation of a tile
 *
 * @name tileToGeoJSON
 * @param {Array<number>} tile
 * @returns {Feature<Polygon>}
 * @example
 * var poly = tileToGeoJSON([5, 10, 10])
 * //=poly
 */
        function tileToGeoJSON(tile) {
            const bbox = tileToBBOX(tile);
            const poly = {
                type: 'Polygon',
                coordinates: [[
                    [bbox[0], bbox[1]],
                    [bbox[0], bbox[3]],
                    [bbox[2], bbox[3]],
                    [bbox[2], bbox[1]],
                    [bbox[0], bbox[1]]
                ]]
            };
            return poly;
        }

        function tile2lon(x, z) {
            return x / Math.pow(2, z) * 360 - 180;
        }

        function tile2lat(y, z) {
            const n = Math.PI - 2 * Math.PI * y / Math.pow(2, z);
            return r2d * Math.atan(0.5 * (Math.exp(n) - Math.exp(-n)));
        }

        /**
 * Get the tile for a point at a specified zoom level
 *
 * @name pointToTile
 * @param {number} lon
 * @param {number} lat
 * @param {number} z
 * @returns {Array<number>} tile
 * @example
 * var tile = pointToTile(1, 1, 20)
 * //=tile
 */
        function pointToTile(lon, lat, z) {
            const tile = pointToTileFraction(lon, lat, z);
            tile[0] = Math.floor(tile[0]);
            tile[1] = Math.floor(tile[1]);
            return tile;
        }

        /**
 * Get the 4 tiles one zoom level higher
 *
 * @name getChildren
 * @param {Array<number>} tile
 * @returns {Array<Array<number>>} tiles
 * @example
 * var tiles = getChildren([5, 10, 10])
 * //=tiles
 */
        function getChildren(tile) {
            return [
                [tile[0] * 2, tile[1] * 2, tile[2] + 1],
                [tile[0] * 2 + 1, tile[1] * 2, tile[2] + 1],
                [tile[0] * 2 + 1, tile[1] * 2 + 1, tile[2] + 1],
                [tile[0] * 2, tile[1] * 2 + 1, tile[2] + 1]
            ];
        }

        /**
 * Get the tile one zoom level lower
 *
 * @name getParent
 * @param {Array<number>} tile
 * @returns {Array<number>} tile
 * @example
 * var tile = getParent([5, 10, 10])
 * //=tile
 */
        function getParent(tile) {
            // top left
            if (tile[0] % 2 === 0 && tile[1] % 2 === 0) {
                return [tile[0] / 2, tile[1] / 2, tile[2] - 1];
            }
            // bottom left
            if ((tile[0] % 2 === 0) && (!tile[1] % 2 === 0)) {
                return [tile[0] / 2, (tile[1] - 1) / 2, tile[2] - 1];
            }
            // top right
            if ((!tile[0] % 2 === 0) && (tile[1] % 2 === 0)) {
                return [(tile[0] - 1) / 2, (tile[1]) / 2, tile[2] - 1];
            }
            // bottom right
            return [(tile[0] - 1) / 2, (tile[1] - 1) / 2, tile[2] - 1];
        }

        function getSiblings(tile) {
            return getChildren(getParent(tile));
        }

        /**
 * Get the 3 sibling tiles for a tile
 *
 * @name getSiblings
 * @param {Array<number>} tile
 * @returns {Array<Array<number>>} tiles
 * @example
 * var tiles = getSiblings([5, 10, 10])
 * //=tiles
 */
        function hasSiblings(tile, tiles) {
            const siblings = getSiblings(tile);
            for (let i = 0; i < siblings.length; i++) {
                if (!hasTile(tiles, siblings[i])) return false;
            }
            return true;
        }

        /**
 * Check to see if an array of tiles contains a particular tile
 *
 * @name hasTile
 * @param {Array<Array<number>>} tiles
 * @param {Array<number>} tile
 * @returns {boolean}
 * @example
 * var tiles = [
 *     [0, 0, 5],
 *     [0, 1, 5],
 *     [1, 1, 5],
 *     [1, 0, 5]
 * ]
 * hasTile(tiles, [0, 0, 5])
 * //=boolean
 */
        function hasTile(tiles, tile) {
            for (let i = 0; i < tiles.length; i++) {
                if (tilesEqual(tiles[i], tile)) return true;
            }
            return false;
        }

        /**
 * Check to see if two tiles are the same
 *
 * @name tilesEqual
 * @param {Array<number>} tile1
 * @param {Array<number>} tile2
 * @returns {boolean}
 * @example
 * tilesEqual([0, 1, 5], [0, 0, 5])
 * //=boolean
 */
        function tilesEqual(tile1, tile2) {
            return (
                tile1[0] === tile2[0] &&
        tile1[1] === tile2[1] &&
        tile1[2] === tile2[2]
            );
        }

        /**
 * Get the quadkey for a tile
 *
 * @name tileToQuadkey
 * @param {Array<number>} tile
 * @returns {string} quadkey
 * @example
 * var quadkey = tileToQuadkey([0, 1, 5])
 * //=quadkey
 */
        function tileToQuadkey(tile) {
            let index = '';
            for (let z = tile[2]; z > 0; z--) {
                let b = 0;
                const mask = 1 << (z - 1);
                if ((tile[0] & mask) !== 0) b++;
                if ((tile[1] & mask) !== 0) b += 2;
                index += b.toString();
            }
            return index;
        }

        /**
 * Get the tile for a quadkey
 *
 * @name quadkeyToTile
 * @param {string} quadkey
 * @returns {Array<number>} tile
 * @example
 * var tile = quadkeyToTile('00001033')
 * //=tile
 */
        function quadkeyToTile(quadkey) {
            let x = 0;
            let y = 0;
            const z = quadkey.length;

            for (let i = z; i > 0; i--) {
                const mask = 1 << (i - 1);
                const q = +quadkey[z - i];
                if (q === 1) x |= mask;
                if (q === 2) y |= mask;
                if (q === 3) {
                    x |= mask;
                    y |= mask;
                }
            }
            return [x, y, z];
        }

        /**
 * Get the smallest tile to cover a bbox
 *
 * @name bboxToTile
 * @param {Array<number>} bbox
 * @returns {Array<number>} tile
 * @example
 * var tile = bboxToTile([ -178, 84, -177, 85 ])
 * //=tile
 */
        function bboxToTile(bboxCoords) {
            const min = pointToTile(bboxCoords[0], bboxCoords[1], 32);
            const max = pointToTile(bboxCoords[2], bboxCoords[3], 32);
            const bbox = [min[0], min[1], max[0], max[1]];

            const z = getBboxZoom(bbox);
            if (z === 0) return [0, 0, 0];
            const x = bbox[0] >>> (32 - z);
            const y = bbox[1] >>> (32 - z);
            return [x, y, z];
        }

        function getBboxZoom(bbox) {
            const MAX_ZOOM = 28;
            for (let z = 0; z < MAX_ZOOM; z++) {
                const mask = 1 << (32 - (z + 1));
                if (((bbox[0] & mask) !== (bbox[2] & mask)) ||
            ((bbox[1] & mask) !== (bbox[3] & mask))) {
                    return z;
                }
            }

            return MAX_ZOOM;
        }

        /**
 * Get the precise fractional tile location for a point at a zoom level
 *
 * @name pointToTileFraction
 * @param {number} lon
 * @param {number} lat
 * @param {number} z
 * @returns {Array<number>} tile fraction
 * var tile = pointToTileFraction(30.5, 50.5, 15)
 * //=tile
 */
        function pointToTileFraction(lon, lat, z) {
            const sin = Math.sin(lat * d2r);
            const z2 = Math.pow(2, z);
            const x = z2 * (lon / 360 + 0.5);
            const y = z2 * (0.5 - 0.25 * Math.log((1 + sin) / (1 - sin)) / Math.PI);
            return [x, y, z];
        }

        module.exports = {
            tileToGeoJSON: tileToGeoJSON,
            tileToBBOX: tileToBBOX,
            getChildren: getChildren,
            getParent: getParent,
            getSiblings: getSiblings,
            hasTile: hasTile,
            hasSiblings: hasSiblings,
            tilesEqual: tilesEqual,
            tileToQuadkey: tileToQuadkey,
            quadkeyToTile: quadkeyToTile,
            pointToTile: pointToTile,
            bboxToTile: bboxToTile,
            pointToTileFraction: pointToTileFraction
        };
    }, {}],
    3: [function(require, module, exports) {
        const cover = require('@mapbox/tile-cover');

        geojsonToQuadkeys = function(poly, limits) {
            return cover.indexes(poly, limits);
        };

        geojsonToQuadints = function(poly, limits) {
            return cover.indexes(poly, limits).map(quadintFromQuadkey);
        };
    }, { '@mapbox/tile-cover': 1 }]
}, {}, [3]);
