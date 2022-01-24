import { version }  from '../package.json';
import {
    bbox,
    kRing,
    kRingDistances,
    sibling,
    toParent,
    toChildren,
    quadkeyFromQuadint,
    quadintFromQuadkey,
    quadintFromLocation,
    quadintToGeoJSON,
    quadintFromZXY,
    geojsonToQuadints,
    ZXYFromQuadint,
    getQuadintResolution
} from '../../shared/javascript/quadkey';

export default {
    bbox,
    kRing,
    kRingDistances,
    sibling,
    toParent,
    toChildren,
    quadkeyFromQuadint,
    quadintFromQuadkey,
    quadintFromLocation,
    quadintToGeoJSON,
    quadintFromZXY,
    geojsonToQuadints,
    ZXYFromQuadint,
    getQuadintResolution,
    version
};