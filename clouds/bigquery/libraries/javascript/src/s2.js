import { S2 } from './s2/index';

export default {
    keyToId: S2.keyToId,
    idToKey: S2.idToKey,
    latLngToKey: S2.latLngToKey,
    FromHilbertQuadKey: S2.S2Cell.FromHilbertQuadKey,
    idToLatLng: S2.idToLatLng
};