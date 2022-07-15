import { version }  from '../package.json';
import {
    getQuadbinPolygon,
    getQuadbinBoundingBox,
    quadbinToTile,
    tileToQuadbin,
    geojsonToQuadbins
} from '../../shared/javascript/quadbin';

export default {
    getQuadbinPolygon,
    getQuadbinBoundingBox,
    quadbinToTile,
    tileToQuadbin,
    geojsonToQuadbins,
    version
};