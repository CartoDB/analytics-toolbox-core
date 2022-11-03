import {
    createPolygonListFromBounds
} from 's2-cell-draw';

import { S2 } from './index';

export function polyfillBbox (minLng, maxLng, minLat, maxLat, resolution) {
    // The bounds cannot be aproximately the same in order createPolygonListFromBounds to work
    // for this reason we ensure a gap between min and max
    const decimalsToRound = 5
    if (Math.round(minLng * Math.pow(10, decimalsToRound)) === Math.round(maxLng * Math.pow(10, decimalsToRound)))
    {
        minLng -= 1 / Math.pow(10, decimalsToRound)
        maxLng += 1 / Math.pow(10, decimalsToRound)
    }
    if (Math.round(minLat * Math.pow(10, decimalsToRound)) === Math.round(maxLat * Math.pow(10, decimalsToRound)))
    {
        minLat -= 1 / Math.pow(10, decimalsToRound)
        maxLat += 1 / Math.pow(10, decimalsToRound)
    }
    const polygonList = createPolygonListFromBounds({
        bounds: [[minLng, minLat], [maxLng, maxLat]],
        level: resolution
    });
    polygonList.map(p => p.S2Key)
    return polygonList.map(p => S2.keyToId(p.S2Key));
}