import { booleanContains, booleanIntersects, intersect, polygon, multiPolygon } from '@turf/turf';
import { h3ToGeoBoundary } from '../src/h3/h3_polyfill/h3core_custom';

export default {
    booleanContains,
    booleanIntersects,
    intersect,
    polygon,
    multiPolygon,
    h3ToGeoBoundary
};