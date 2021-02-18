const fs = require('fs');
const assert = require('assert').strict;
const chaiAssert = require('chai').assert;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../s2_library.js') + '');

describe('S2 unit tests', () => {
    it('Version', async() => {
        assert.equal(s2Version(), 1);
    });

    it('Quadkey/S2 id Conversions', async() => {
        let level = 10;
        let latitude = 10;
        let longitude = -20;
        const quadkey = S2.latLngToKey(latitude, longitude, level);
        assert.equal(quadkey, S2.idToKey(S2.keyToId(quadkey)));

        level = 11;
        latitude = 15;
        longitude = -25;
        const s2Id = S2.latLngToId(latitude, longitude, level);
        assert.equal(s2Id, S2.keyToId(S2.idToKey(s2Id)));
    });

    it('Long Lat id Conversions', async() => {
        const level = 18;
        const latitude = -14;
        const longitude = 125;
        const quadkey = S2.latLngToKey(latitude, longitude, level);
        const s2Id = S2.latLngToId(latitude, longitude, level);
        assert.equal(quadkey, S2.idToKey(s2Id));
        chaiAssert.closeTo(-14, S2.idToLatLng(s2Id).lat, 0.001);
        chaiAssert.closeTo(-14, S2.keyToLatLng(quadkey).lat, 0.001);
        chaiAssert.closeTo(125, S2.idToLatLng(s2Id).lng, 0.001);
        chaiAssert.closeTo(125, S2.keyToLatLng(quadkey).lng, 0.001);
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
