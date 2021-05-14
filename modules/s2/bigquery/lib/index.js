import { version }  from '../package.json';
import { S2 } from './s2geometry';

export default {
    keyToId: S2.keyToId,
    idToKey: S2.idToKey,
    latLngToKey: S2.latLngToKey,
    FromHilbertQuadKey: S2.S2Cell.FromHilbertQuadKey,
    version
};
