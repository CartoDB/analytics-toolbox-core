import { version }  from '../package.json';
import {
    getQuadbinPolygon,
    quadbinToTile,
    tileToQuadbin,
    geojsonToQuadbins
} from '../../shared/javascript/quadbin';

export default {
    getQuadbinPolygon,
    quadbinToTile,
    tileToQuadbin,
    geojsonToQuadbins,
    version
};