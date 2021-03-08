const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../s2_library.js') + '');

describe('S2 unit tests', () => {
    it('Version', async() => {
        assert.equal(s2Version(), '1.2.10');
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

    it('Quadkey to S2 id static conversions', async() => {
        assert.equal(S2.keyToId('4/12').toString(), '-8286623314361712640');
        assert.equal(S2.keyToId('2/02300033').toString(), '5008548143403368448');
        assert.equal(S2.keyToId('3/03131200023201').toString(), '7416309021449125888');
        assert.equal(S2.keyToId('5/0001221313222222120').toString(), '-6902629179221606400');
        assert.equal(S2.keyToId('2/0221200002312111222332101').toString(), '4985491052606295040');
        assert.equal(S2.keyToId('5/1331022022103232320303230131').toString(), '-5790199077674720336');
    });

    it('S2 id to quadkey static conversions', async() => {
        assert.equal(S2.idToKey('-5062045981164437504'), '5/303');
        assert.equal(S2.idToKey('5159154848129613824'), '2/033030');
        assert.equal(S2.idToKey('3776858106818985984'), '1/220311003003');
        assert.equal(S2.idToKey('-6531506317872332800'), '5/022231231230313331');
        assert.equal(S2.idToKey('7380675754284404736'), '3/030312231223330330032232');
        assert.equal(S2.idToKey('1996857078240356732'), '0/31312302011313121331323110233');
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
