// Oracle MLE entry point for the h3 library.
// Exports are bound by SQL functions via `AS MLE MODULE h3_module SIGNATURE '...'`.
//
// Pinned to h3-js 3.7.2.
//
// Polyfill exposes only CENTER mode here (h3-js v3 doesn't natively
// support other modes). The intersects/contains variants are post-filters
// in PL/SQL via SDO_GEOM.RELATE.

import * as h3Lib from 'h3-js';

function safeCall (fn, fallback) {
    try {
        const result = fn();
        return result === undefined ? fallback : result;
    } catch (_) {
        return fallback;
    }
}

// h3-js v3 doesn't validate cell inputs — it processes any hex string and
// returns garbage for non-H3 inputs. Guard each entry point with h3IsValid
// to honour the NULL-on-invalid convention.
function isValid (h3) {
    return safeCall(() => h3Lib.h3IsValid(h3), false);
}

/** k-ring (filled disk) of `origin` at distance `k`. */
export function kring (origin, k) {
    if (origin === null || k === null) return '[]';
    const kNum = Number(k);
    if (kNum < 0 || !isValid(origin)) return '[]';
    return JSON.stringify(safeCall(() => h3Lib.kRing(origin, kNum), []));
}

/** Hollow ring at exact distance `k`. h3-js throws when crossing pentagon
 *  distortion; we surface that as an empty array (matches BQ/SF). */
export function hexring (origin, k) {
    if (origin === null || k === null) return '[]';
    const kNum = Number(k);
    if (kNum < 0 || !isValid(origin)) return '[]';
    return JSON.stringify(safeCall(() => h3Lib.hexRing(origin, kNum), []));
}

/** k-ring with each cell's distance from origin.
 *  Returns JSON array of {h3, distance}. */
export function kringDistances (origin, k) {
    if (origin === null || k === null) return '[]';
    const kNum = Number(k);
    if (kNum < 0 || !isValid(origin)) return '[]';
    return JSON.stringify(safeCall(() => {
        const rings = h3Lib.kRingDistances(origin, kNum);
        const out = [];
        for (let d = 0; d < rings.length; d++) {
            for (const h3 of rings[d]) out.push({ h3, distance: d });
        }
        return out;
    }, []));
}

/** Grid distance between two cells. h3-js v3 returns -1 on
 *  unreachable / different-resolution / pentagon-crossing pairs;
 *  surface that as null. */
export function distance (origin, destination) {
    if (origin === null || destination === null) return null;
    if (!isValid(origin) || !isValid(destination)) return null;
    return safeCall(() => {
        const d = h3Lib.h3Distance(origin, destination);
        return d < 0 ? null : d;
    }, null);
}

/** Children of `parent` at the (finer) target resolution. */
export function toChildren (parent, resolution) {
    if (parent === null || resolution === null) return '[]';
    if (!isValid(parent)) return '[]';
    return JSON.stringify(safeCall(
        () => h3Lib.h3ToChildren(parent, Number(resolution)),
        []
    ));
}

/** Compact a set of same-resolution cells. Input is a JSON array string.
 *  Dedupes input before calling h3-js (defensive: h3lib's compactCells
 *  errors on duplicates). */
export function compact (cellsJson) {
    if (cellsJson === null) return '[]';
    return JSON.stringify(safeCall(
        () => h3Lib.compact(Array.from(new Set(JSON.parse(cellsJson)))),
        []
    ));
}

/** Uncompact (expand) a set of cells to a single resolution.
 *  Dedupes input before expanding (defensive: duplicate inputs would
 *  produce duplicate children). */
export function uncompact (cellsJson, resolution) {
    if (cellsJson === null || resolution === null) return '[]';
    return JSON.stringify(safeCall(
        () => h3Lib.uncompact(
            Array.from(new Set(JSON.parse(cellsJson))),
            Number(resolution)
        ),
        []
    ));
}

/** Polyfill a GeoJSON Polygon / MultiPolygon at the given resolution.
 *  Returns CENTER-mode cells via h3-js polyfill. The PL/SQL layer
 *  post-filters with SDO_GEOM.RELATE to derive intersects/contains.
 *
 *  Non-polygon geometries (Point, LineString, etc.) and members of a
 *  GeometryCollection that aren't polygons are silently ignored. */
export function polyfill (geojson, resolution) {
    if (geojson === null || resolution === null) return '[]';
    return JSON.stringify(safeCall(() => {
        const geom = JSON.parse(geojson);
        const res = Number(resolution);
        const set = new Set();
        const visit = (g) => {
            if (!g) return;
            if (g.type === 'Polygon') {
                // h3-js polyfill expects an array of rings; isGeoJson=true
                // tells it to interpret coordinates as [lng, lat].
                for (const c of h3Lib.polyfill(g.coordinates, res, true)) set.add(c);
            } else if (g.type === 'MultiPolygon') {
                for (const polyCoords of g.coordinates) {
                    for (const c of h3Lib.polyfill(polyCoords, res, true)) set.add(c);
                }
            } else if (g.type === 'GeometryCollection') {
                for (const sub of g.geometries) visit(sub);
            }
            // Other geometry types are ignored.
        };
        visit(geom);
        return Array.from(set);
    }, []));
}
