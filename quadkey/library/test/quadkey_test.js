const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../quadkey_library.js') + '');

describe('QUADKEY unit tests', () => {
    it('Version', async() => {
        assert.equal(quadkeyVersion(), '1');
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

    it('KRING should work', async() => {
        assert.deepEqual(kring(162, 1).sort().map(String), ['130', '162', '194',
            '2', '258', '290',
            '322', '34', '66']);
        assert.deepEqual(kring(12070922, 1).sort().map(String), ['12038122', '12038154',
            '12038186', '12070890',
            '12070922', '12070954',
            '12103658', '12103690',
            '12103722']);
        assert.deepEqual(kring(791040491538, 1).sort().map(String), ['791032102898',
            '791032102930',
            '791032102962',
            '791040491506',
            '791040491538',
            '791040491570',
            '791048880114',
            '791048880146',
            '791048880178']);
        assert.deepEqual(kring(12960460429066265n, 1).sort().map(String), ['12960459355324409',
            '12960459355324441',
            '12960459355324473',
            '12960460429066233',
            '12960460429066265',
            '12960460429066297',
            '12960461502808057',
            '12960461502808089',
            '12960461502808121']);
        assert.deepEqual(kring(12070922, 2).sort().map(String), ['12005322', '12005354', '12005386',
            '12005418', '12005450', '12038090',
            '12038122', '12038154', '12038186',
            '12038218', '12070858', '12070890',
            '12070922', '12070954', '12070986',
            '12103626', '12103658', '12103690',
            '12103722', '12103754', '12136394',
            '12136426', '12136458', '12136490',
            '12136522']);
        assert.deepEqual(kring(791040491538, 3).sort().map(String), ['791015325618', '791015325650', '791015325682',
            '791015325714', '791015325746', '791015325778',
            '791015325810', '791023714226', '791023714258',
            '791023714290', '791023714322', '791023714354',
            '791023714386', '791023714418', '791032102834',
            '791032102866', '791032102898', '791032102930',
            '791032102962', '791032102994', '791032103026',
            '791040491442', '791040491474', '791040491506',
            '791040491538', '791040491570', '791040491602',
            '791040491634', '791048880050', '791048880082',
            '791048880114', '791048880146', '791048880178',
            '791048880210', '791048880242', '791057268658',
            '791057268690', '791057268722', '791057268754',
            '791057268786', '791057268818', '791057268850',
            '791065657266', '791065657298', '791065657330',
            '791065657362', '791065657394', '791065657426',
            '791065657458']);
    });
});
