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
    ZXYFromQuadint
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
    version
};