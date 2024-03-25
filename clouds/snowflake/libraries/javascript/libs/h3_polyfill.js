import { booleanContains, booleanIntersects, geometryCollection, intersect, polygon } from '@turf/turf';
import { h3ToGeoBoundary } from '../src/h3/h3_polyfill/h3core_custom';

export default {
    booleanContains,
    booleanIntersects,
    geometryCollection,
    intersect,
    polygon,
    h3ToGeoBoundary
};