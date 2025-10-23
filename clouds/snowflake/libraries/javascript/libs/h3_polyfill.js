import { booleanContains, booleanIntersects, intersect as turfIntersect, polygon, multiPolygon, featureCollection } from '@turf/turf';
import { h3ToGeoBoundary } from '../src/h3/h3_polyfill/h3core_custom';

// Wrapper for turf 7.x intersect API compatibility
// Turf 7.x requires a FeatureCollection instead of two separate features
function intersect (feat1, feat2, options) {
    if (!feat1 || !feat2) {
        return null;
    }

    try {
        // Wrap raw geometries as Features if needed
        const f1 = feat1.type === 'Feature' ? feat1 : { type: 'Feature', properties: {}, geometry: feat1 };
        const f2 = feat2.type === 'Feature' ? feat2 : { type: 'Feature', properties: {}, geometry: feat2 };

        const fc = featureCollection([f1, f2]);
        const result = turfIntersect(fc, options);
        return result || null;
    } catch (e) {
        return null;
    }
}

export default {
    booleanContains,
    booleanIntersects,
    intersect,
    polygon,
    multiPolygon,
    h3ToGeoBoundary
};