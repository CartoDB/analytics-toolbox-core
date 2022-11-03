import {
    createPolygonListFromBounds
} from 's2-cell-draw';

import { S2 } from './index';

export function polyfillBbox (minLng, maxLng, minLat, maxLat, resolution) {
    const polygonList = createPolygonListFromBounds({
        bounds: [[minLng, minLat], [maxLng, maxLat]],
        level: resolution
    });
    polygonList.map(p => p.S2Key)
    return polygonList.map(p => S2.keyToId(p.S2Key));
}