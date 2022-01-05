import { version }  from '../package.json';
import {
    bbox,
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