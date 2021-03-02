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

    it('Inside should work at any level of zoom', async() => {
        let z, lat, lng;
        for (z = 0; z < 30; ++z) {
            for (lat = -90; lat <= 90; lat = lat + 15) {
                for (lng = -180; lng <= 180; lng = lng + 15) {
                    const location = { lng: lng, lat: lat };
                    const quadint = quadintFromLocation(location, z);
                    assert.ok(inside(location, quadint));
                }
            }
        }
    });

    it('A quadint should be contained inside his parent at any level of zoom', async() => {
        let z, lat, lng;
        for (z = 1; z < 30; ++z) {
            for (lat = -90; lat <= 90; lat = lat + 15) {
                for (lng = -180; lng <= 180; lng = lng + 15) {
                    const location = { lng: lng, lat: lat };
                    const quadint = quadintFromLocation(location, z);
                    assert.ok(inside(location, parent(quadint)));
                }
            }
        }
    });

    it('Parent should work at any level of zoom', async() => {
        let z, lat, lng;
        for (z = 1; z < 30; ++z) {
            for (lat = -90; lat <= 90; lat = lat + 15) {
                for (lng = -180; lng <= 180; lng = lng + 15) {
                    const location = { lng: lng, lat: lat };
                    const quadint = quadintFromLocation(location, z);
                    const currentParent = quadintFromLocation(location, z - 1);
                    assert.equal(currentParent, parent(quadint));
                }
            }
        }
    });

    it('Children should work at any level of zoom', async() => {
        let z, lat, lng, cont;
        for (z = 0; z < 29; ++z) {
            for (lat = -90; lat <= 90; lat = lat + 15) {
                for (lng = -180; lng <= 180; lng = lng + 15) {
                    const location = { lng: lng, lat: lat };
                    const quadint = quadintFromLocation(location, z);
                    const currentChild = quadintFromLocation(location, z + 1);
                    const childs = children(quadint);
                    cont = 0;
                    childs.forEach((element) => {
                        if (currentChild === element) {
                            ++cont;
                        }
                    });
                    assert.equal(cont, 1);
                }
            }
        }
    });
});
