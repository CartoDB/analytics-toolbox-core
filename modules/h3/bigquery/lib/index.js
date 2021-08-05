import { version }  from '../package.json';
import { geoToH3, compact, h3Distance, h3IsValid, hexRing, h3IsPentagon, kRing, polyfill, h3ToGeoBoundary, h3ToChildren, h3ToParent, uncompact, experimentalH3ToLocalIj, experimentalLocalIjToH3} from 'h3-js';

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
    experimentalH3ToLocalIj,
    version
};