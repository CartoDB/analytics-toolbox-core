import { version }  from '../package.json';
import { geoToH3, compact, h3Distance, h3GetResolution, h3IsValid, hexRing, h3IsPentagon, kRing, kRingDistances, polyfill, h3ToGeo, h3ToGeoBoundary, h3ToChildren, h3ToParent, uncompact } from 'h3-js';
import { bboxClip, bbox, bboxPolygon } from '@turf/turf';


export default {
    geoToH3,
    compact,
    h3Distance,
    h3GetResolution,
    h3IsValid,
    hexRing,
    h3IsPentagon,
    kRing,
    kRingDistances,
    polyfill,
    h3ToGeo,
    h3ToGeoBoundary,
    h3ToChildren,
    h3ToParent,
    uncompact,
    bboxClip,
    bbox,
    bboxPolygon,
    version
};