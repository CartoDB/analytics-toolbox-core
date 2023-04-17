import { geoToH3, compact, h3Distance, h3GetResolution, h3IsValid, hexRing, h3IsPentagon, kRing, kRingDistances, polyfill, h3ToGeo, h3ToGeoBoundary, h3ToChildren, h3ToParent, uncompact } from 'h3-js';
import { bboxClip } from '@turf/turf';

function removeNextDuplicates (coordinates) {
    const precision = 0.0000000000001;
    const uniqueCoordinates = [];

    for (let i = 0; i < coordinates.length; i++) {
        if (i == coordinates.length - 1 ||
            (Math.abs(coordinates[i][0] - coordinates[i+1][0]) > precision &&
             Math.abs(coordinates[i][1] - coordinates[i+1][1]) > precision)) {
            uniqueCoordinates.push(coordinates[i])
        }
    }

    return uniqueCoordinates;
}

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
    removeNextDuplicates
};
