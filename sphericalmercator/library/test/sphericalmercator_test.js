const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../sphericalmercator_library.js') + '');

describe('SPHERICALMERCATOR unit tests', () => {
    it('Version', async() => {
        assert.equal(sphericalmercatorVersion(), 1);
    });

    const sm = new SphericalMercator();
    const MAX_EXTENT_MERC = [-20037508.342789244, -20037508.342789244, 20037508.342789244, 20037508.342789244];
    const MAX_EXTENT_WGS84 = [-180, -85.0511287798066, 180, 85.0511287798066];

    it('bbox', async() => {
        assert.deepEqual(sm.bbox(0, 0, 0, true, 'WGS84'), [-180, -85.05112877980659, 180, 85.0511287798066]);
        assert.deepEqual(sm.bbox(0, 0, 1, true, 'WGS84'), [-180, -85.05112877980659, 0, 0]);
    });

    it('xyz', async() => {
        assert.deepEqual(sm.xyz([-180, -85.05112877980659, 180, 85.0511287798066], 0, true, 'WGS84'), { minX: 0, minY: 0, maxX: 0, maxY: 0 });
        assert.deepEqual(sm.xyz([-180, -85.05112877980659, 0, 0], 1, true, 'WGS84'), { minX: 0, minY: 0, maxX: 0, maxY: 0 });
    });

    it('xyz-broken', async() => {
        const extent = [-0.087891, 40.95703, 0.087891, 41.044916];
        const xyz = sm.xyz(extent, 3, true, 'WGS84');
        assert.equal(xyz.minX <= xyz.maxX, true, 'x: ' + xyz.minX + ' <= ' + xyz.maxX + ' for ' + JSON.stringify(extent));
        assert.equal(xyz.minY <= xyz.maxY, true, 'y: ' + xyz.minY + ' <= ' + xyz.maxY + ' for ' + JSON.stringify(extent));
    });

    it('xyz-negative', async() => {
        const extent = [-112.5, 85.0511, -112.5, 85.0511];
        const xyz = sm.xyz(extent, 0);
        assert.equal(xyz.minY, 0, 'returns zero for y value');
    });

    it('xyz-fuzz', async() => {
        for (let i = 0; i < 1000; i++) {
            const x = [-180 + (360 * Math.random()), -180 + (360 * Math.random())];
            const y = [-85 + (170 * Math.random()), -85 + (170 * Math.random())];
            const z = Math.floor(22 * Math.random());
            const extent = [
                Math.min.apply(Math, x),
                Math.min.apply(Math, y),
                Math.max.apply(Math, x),
                Math.max.apply(Math, y)
            ];
            const xyz = sm.xyz(extent, z, true, 'WGS84');
            if (xyz.minX > xyz.maxX) {
                assert.equal(xyz.minX <= xyz.maxX, true, 'x: ' + xyz.minX + ' <= ' + xyz.maxX + ' for ' + JSON.stringify(extent));
            }
            if (xyz.minY > xyz.maxY) {
                assert.equal(xyz.minY <= xyz.maxY, true, 'y: ' + xyz.minY + ' <= ' + xyz.maxY + ' for ' + JSON.stringify(extent));
            }
        }
    });

    it('convert', async() => {
        assert.deepEqual(
            sm.convert(MAX_EXTENT_WGS84, '900913'),
            MAX_EXTENT_MERC
        );
        assert.deepEqual(
            sm.convert(MAX_EXTENT_MERC, 'WGS84'),
            MAX_EXTENT_WGS84
        );
    });

    it('extents', async() => {
        assert.deepEqual(
            sm.convert([-240, -90, 240, 90], '900913'),
            MAX_EXTENT_MERC
        );
        assert.deepEqual(
            sm.xyz([-240, -90, 240, 90], 4, true, 'WGS84'), {
                minX: 0,
                minY: 0,
                maxX: 15,
                maxY: 15
            },
            'Maximum extents enforced on conversion to tile ranges.'
        );
    });

    it('ll', async() => {
        assert.deepEqual(
            sm.ll([200, 200], 9),
            [-179.45068359375, 85.00351401304403],
            'LL with int zoom value converts'
        );
        assert.deepEqual(
            sm.ll([200, 200], 8.6574),
            [-179.3034449476476, 84.99067388699072],
            'LL with float zoom value converts'
        );
    });

    it('px', async() => {
        assert.deepEqual(
            sm.px([-179, 85], 9),
            [364, 215],
            'PX with int zoom value converts'
        );
        assert.deepEqual(
            sm.px([-179, 85], 8.6574),
            [287.12734093961626, 169.30444219392666],
            'PX with float zoom value converts'
        );
    });

    it('high precision float', async() => {
        const withInt = sm.ll([200, 200], 4);
        const withFloat = sm.ll([200, 200], 4.0000000001);

        function round(val) {
            return parseFloat(val).toFixed(6);
        }

        assert.equal(round(withInt[0]), round(withFloat[0]), 'first six decimals are the same');
        assert.equal(round(withInt[1]), round(withFloat[1]), 'first six decimals are the same');
    });
});
