const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../s2_library.js') + '');

describe('S2 unit tests', () => {
    it('Version', async() => {
        assert.equal(s2Version(), 1);
    });

    it('Quadkey/S2 id Conversions', async() => {
        let z, lat, lng;
        for (z = 1; z < 30; ++z) {
            for (lat = -89; lat <= 89; lat = lat + 15) {
                for (lng = -179; lng <= 179; lng = lng + 15) {
                    const quadkey = S2.latLngToKey(lat, lng, z);
                    assert.equal(quadkey, S2.idToKey(S2.keyToId(quadkey)));
                    
                    const s2Id = S2.latLngToId(lat, lng, z);
                    assert.equal(s2Id, S2.keyToId(S2.idToKey(s2Id)));
                }
            }    
        }
    });

    it('Boundary check', async() => {
        const level = 18;
        const latitude = -14;
        const longitude = 125;
        const bounds = [
            { lat: -14.000016145055083, lng: 124.99991607494462 },
            { lat: -13.99970528488021, lng: 124.99991607494462 },
            { lat: -13.999648690569117, lng: 125.0002604046465 },
            { lat: -13.999959549588995, lng: 125.0002604046465 }
        ];
        const testBoundary = S2.S2Cell.FromLatLng({ lat: latitude, lng: longitude }, level).getCornerLatLngs();
        assert.deepEqual(bounds, testBoundary);
    });
});
