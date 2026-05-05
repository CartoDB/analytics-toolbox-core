// Oracle MLE entry point for the quadbin library.
// Exports are bound by SQL functions via `AS MLE MODULE quadbin_module SIGNATURE '...'`.
//
// JSON serialization keeps quadbin indices as STRINGS to preserve full
// 64-bit precision through the PL/SQL ↔ JS boundary (JS Number can only
// represent integers up to 2^53; quadbin indices at z>=14 exceed that).

import { geojsonToQuadbins } from '../src/quadbin';

/**
 * Polyfill a GeoJSON geometry with quadbin tiles at the given resolution.
 * Returns a JSON array of quadbin index strings.
 *
 * @param {string} geojson - GeoJSON geometry as a JSON string
 * @param {number} resolution - target zoom level [0..26]
 * @returns {string} JSON array of quadbin indices (as strings)
 */
export function polyfill (geojson, resolution) {
    if (geojson === null || resolution === null) return '[]';
    const geom = JSON.parse(geojson);
    const opts = { min_zoom: resolution, max_zoom: resolution };
    let quadbins;
    if (geom.type === 'GeometryCollection') {
        quadbins = [];
        for (const sub of geom.geometries) {
            quadbins = quadbins.concat(geojsonToQuadbins(sub, opts));
        }
        quadbins = Array.from(new Set(quadbins));
    } else {
        quadbins = geojsonToQuadbins(geom, opts);
    }
    return JSON.stringify(quadbins);
}