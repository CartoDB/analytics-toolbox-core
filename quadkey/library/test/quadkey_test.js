const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../quadkey_library.js') + '');

describe('QUADKEY unit tests', () => {
    it('Version', async() => {
        assert.equal(quadkeyVersion(), 1);
    });

    it('Should be able to encode/decode tiles at any level of zoom', async() => {
        let tilesPerLevel, x, y, xDecoded, yDecoded, zDecoded;
        for (let z = 0; z < 30; ++z) {
            if (z === 0) {
                tilesPerLevel = 1;
            } else {
                tilesPerLevel = 2 << (z - 1);
            }

            x = 0;
            y = 0;
            let zxyDecoded = ZXYFromQuadint(quadintFromZXY(z, x, y));
            zDecoded = zxyDecoded.z;
            xDecoded = zxyDecoded.x;
            yDecoded = zxyDecoded.y;
            assert.ok(z === zDecoded && x === xDecoded && y === yDecoded);

            if (z > 0) {
                x = tilesPerLevel / 2;
                y = tilesPerLevel / 2;
                zxyDecoded = ZXYFromQuadint(quadintFromZXY(z, x, y));
                zDecoded = zxyDecoded.z;
                xDecoded = zxyDecoded.x;
                yDecoded = zxyDecoded.y;
                assert.ok(z === zDecoded && x === xDecoded && y === yDecoded);

                x = tilesPerLevel - 1;
                y = tilesPerLevel - 1;
                zxyDecoded = ZXYFromQuadint(quadintFromZXY(z, x, y));
                zDecoded = zxyDecoded.z;
                xDecoded = zxyDecoded.x;
                yDecoded = zxyDecoded.y;
                assert.ok(z === zDecoded && x === xDecoded && y === yDecoded);
            }
        }
    });

    it('Should be able to encode/decode between quadint and quadkey at any level of zoom', async() => {
        let tilesPerLevel, x, y, xDecoded, yDecoded, zDecoded;
        for (let z = 0; z < 30; ++z) {
            if (z === 0) {
                tilesPerLevel = 1;
            } else {
                tilesPerLevel = 2 << (z - 1);
            }

            x = 0;
            y = 0;
            let zxyDecoded = ZXYFromQuadint(quadintFromQuadkey(quadkeyFromQuadint(quadintFromZXY(z, x, y))));
            zDecoded = zxyDecoded.z;
            xDecoded = zxyDecoded.x;
            yDecoded = zxyDecoded.y;
            assert.ok(z === zDecoded && x === xDecoded && y === yDecoded);

            if (z > 0) {
                x = tilesPerLevel / 2;
                y = tilesPerLevel / 2;
                zxyDecoded = ZXYFromQuadint(quadintFromQuadkey(quadkeyFromQuadint(quadintFromZXY(z, x, y))));
                zDecoded = zxyDecoded.z;
                xDecoded = zxyDecoded.x;
                yDecoded = zxyDecoded.y;
                assert.ok(z === zDecoded && x === xDecoded && y === yDecoded);

                x = tilesPerLevel - 1;
                y = tilesPerLevel - 1;
                zxyDecoded = ZXYFromQuadint(quadintFromQuadkey(quadkeyFromQuadint(quadintFromZXY(z, x, y))));
                zDecoded = zxyDecoded.z;
                xDecoded = zxyDecoded.x;
                yDecoded = zxyDecoded.y;
                assert.ok(z === zDecoded && x === xDecoded && y === yDecoded);
            }
        }
    });

    it('ToParent should work at any level of zoom', async() => {
        let z, lat, lng;
        for (z = 1; z < 30; ++z) {
            for (lat = -90; lat <= 90; lat = lat + 15) {
                for (lng = -180; lng <= 180; lng = lng + 15) {
                    const quadint = quadintFromLocation(lng, lat, z);
                    const currentParent = quadintFromLocation(lng, lat, z - 1);
                    assert.equal(currentParent, toParent(quadint, z - 1));
                }
            }
        }
        for (z = 5; z < 30; ++z) {
            for (lat = -90; lat <= 90; lat = lat + 15) {
                for (lng = -180; lng <= 180; lng = lng + 15) {
                    const quadint = quadintFromLocation(lng, lat, z);
                    const currentParent = quadintFromLocation(lng, lat, z - 5);
                    assert.equal(currentParent, toParent(quadint, z - 5));
                }
            }
        }
        for (z = 10; z < 30; ++z) {
            for (lat = -90; lat <= 90; lat = lat + 15) {
                for (lng = -180; lng <= 180; lng = lng + 15) {
                    const quadint = quadintFromLocation(lng, lat, z);
                    const currentParent = quadintFromLocation(lng, lat, z - 10);
                    assert.equal(currentParent, toParent(quadint, z - 10));
                }
            }
        }
    });

    it('ToChildren should work at any level of zoom', async() => {
        let z, lat, lng;
        for (z = 0; z < 29; ++z) {
            for (lat = 90; lat <= 90; lat = lat + 15) {
                for (lng = -180; lng <= 180; lng = lng + 15) {
                    const quadint = quadintFromLocation(lng, lat, z);
                    const childs = toChildren(quadint, z + 1);
                    childs.forEach((element) => {
                        assert.equal(toParent(element, z), quadint);
                    });
                }
            }
        }

        for (z = 0; z < 25; ++z) {
            for (lat = 90; lat <= 90; lat = lat + 15) {
                for (lng = -180; lng <= 180; lng = lng + 15) {
                    const quadint = quadintFromLocation(lng, lat, z);
                    const childs = toChildren(quadint, z + 5);
                    childs.forEach((element) => {
                        assert.equal(toParent(element, z), quadint);
                    });
                }
            }
        }
    });

    it('Sibling should work at any level of zoom', async() => {
        let z, lat, lng;
        for (z = 0; z < 29; ++z) {
            for (lat = -90; lat <= 90; lat = lat + 15) {
                for (lng = -180; lng <= 180; lng = lng + 15) {
                    const quadint = quadintFromLocation(lng, lat, z);
                    let siblingQuadint = sibling(quadint, 'right');
                    siblingQuadint = sibling(siblingQuadint, 'up');
                    siblingQuadint = sibling(siblingQuadint, 'left');
                    siblingQuadint = sibling(siblingQuadint, 'down');
                    assert.equal(quadint, siblingQuadint);
                }
            }
        }
    });

    it('BBOX should work', async() => {
        assert.deepEqual(bbox(162), [-90, 0, 0, 66.51326044311186]);
        assert.deepEqual(bbox(12070922), [-45, 44.840290651397986, -44.6484375, 45.08903556483103]);
        assert.deepEqual(bbox(791040491538), [-45, 44.99976701918129, -44.998626708984375, 45.00073807829068]);
        assert.deepEqual(bbox(12960460429066265n), [-45, 44.999994612636684, -44.99998927116394, 45.00000219906962]);
    });
});
