import {
    feature,
    centerMean,
    centerMedian,
    centerOfMass,
    pointOnFeature
} from '@turf/turf';

export default {
    feature,
    centerMean,
    centerMedian,
    centerOfMass,
    pointOnSurface: pointOnFeature  // Renamed from pointOnSurface in turf 7.x
};