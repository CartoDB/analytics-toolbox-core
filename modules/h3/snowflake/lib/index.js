import { version }  from '../package.json';
import { geoToH3, compact, h3Distance, h3IsValid, hexRing, h3IsPentagon, kRing, polyfill, h3ToGeoBoundary, h3ToChildren, h3ToParent, uncompact } from 'h3-js';

export default {
    geoToH3,
    compact,
    h3Distance,
    h3IsValid,
    hexRing,
    h3IsPentagon,
    kRing,
    polyfill,
    h3ToGeoBoundary,
    h3ToChildren,
    h3ToParent,
    uncompact,
    version
};
