const lib = require('../build/index');

// TODO: refactor tests

test('bbox should work', () => {
    expect(lib.quadkey.bbox(162)).toEqual([-90, 0, 0, 66.51326044311186]);
    expect(lib.quadkey.bbox(12070922)).toEqual([-45, 44.840290651397986, -44.6484375, 45.08903556483103]);
    expect(lib.quadkey.bbox(791040491538)).toEqual([-45, 44.99976701918129, -44.998626708984375, 45.00073807829068]);
    expect(lib.quadkey.bbox(12960460429066265n)).toEqual([-45, 44.999994612636684, -44.99998927116394, 45.00000219906962]);
});

test('toParent should work at any level of zoom', () => {
    let z, lat, lng;
    for (z = 1; z < 30; ++z) {
        for (lat = -90; lat <= 90; lat = lat + 15) {
            for (lng = -180; lng <= 180; lng = lng + 15) {
                const quadint = lib.quadkey.quadintFromLocation(lng, lat, z);
                const currentParent = lib.quadkey.quadintFromLocation(lng, lat, z - 1);
                expect(currentParent).toEqual(lib.quadkey.toParent(quadint, z - 1));
            }
        }
    }
    for (z = 5; z < 30; ++z) {
        for (lat = -90; lat <= 90; lat = lat + 15) {
            for (lng = -180; lng <= 180; lng = lng + 15) {
                const quadint = lib.quadkey.quadintFromLocation(lng, lat, z);
                const currentParent = lib.quadkey.quadintFromLocation(lng, lat, z - 5);
                expect(currentParent).toEqual(lib.quadkey.toParent(quadint, z - 5));
            }
        }
    }
    for (z = 10; z < 30; ++z) {
        for (lat = -90; lat <= 90; lat = lat + 15) {
            for (lng = -180; lng <= 180; lng = lng + 15) {
                const quadint = lib.quadkey.quadintFromLocation(lng, lat, z);
                const currentParent = lib.quadkey.quadintFromLocation(lng, lat, z - 10);
                expect(currentParent).toEqual(lib.quadkey.toParent(quadint, z - 10));
            }
        }
    }
});

test('toChildren should work at any level of zoom', () => {
    let z, lat, lng;
    for (z = 0; z < 29; ++z) {
        for (lat = 90; lat <= 90; lat = lat + 15) {
            for (lng = -180; lng <= 180; lng = lng + 15) {
                const quadint = lib.quadkey.quadintFromLocation(lng, lat, z);
                const childs = lib.quadkey.toChildren(quadint, z + 1);
                childs.forEach((element) => {
                    expect(lib.quadkey.toParent(element, z)).toEqual(quadint);
                });
            }
        }
    }

    for (z = 0; z < 25; ++z) {
        for (lat = 90; lat <= 90; lat = lat + 15) {
            for (lng = -180; lng <= 180; lng = lng + 15) {
                const quadint = lib.quadkey.quadintFromLocation(lng, lat, z);
                const childs = lib.quadkey.toChildren(quadint, z + 5);
                childs.forEach((element) => {
                    expect(lib.quadkey.toParent(element, z)).toEqual(quadint);
                });
            }
        }
    }
});

test('Should be able to encode/decode between quadint and quadkey at any level of zoom', async () => {
    let tilesPerLevel, x, y, xDecoded, yDecoded, zDecoded;
    for (let z = 0; z < 30; ++z) {
        if (z === 0) {
            tilesPerLevel = 1;
        } else {
            tilesPerLevel = 2 << (z - 1);
        }

        x = 0;
        y = 0;
        let zxyDecoded = lib.quadkey.ZXYFromQuadint(lib.quadkey.quadintFromQuadkey(lib.quadkey.quadkeyFromQuadint(lib.quadkey.quadintFromZXY(z, x, y))));
        zDecoded = zxyDecoded.z;
        xDecoded = zxyDecoded.x;
        yDecoded = zxyDecoded.y;
        expect(z === zDecoded && x === xDecoded && y === yDecoded).toBeTruthy();

        if (z > 0) {
            x = tilesPerLevel / 2;
            y = tilesPerLevel / 2;
            zxyDecoded = lib.quadkey.ZXYFromQuadint(lib.quadkey.quadintFromQuadkey(lib.quadkey.quadkeyFromQuadint(lib.quadkey.quadintFromZXY(z, x, y))));
            zDecoded = zxyDecoded.z;
            xDecoded = zxyDecoded.x;
            yDecoded = zxyDecoded.y;
            expect(z === zDecoded && x === xDecoded && y === yDecoded).toBeTruthy();

            x = tilesPerLevel - 1;
            y = tilesPerLevel - 1;
            zxyDecoded = lib.quadkey.ZXYFromQuadint(lib.quadkey.quadintFromQuadkey(lib.quadkey.quadkeyFromQuadint(lib.quadkey.quadintFromZXY(z, x, y))));
            zDecoded = zxyDecoded.z;
            xDecoded = zxyDecoded.x;
            yDecoded = zxyDecoded.y;
            expect(z === zDecoded && x === xDecoded && y === yDecoded).toBeTruthy();
        }
    }
});

test('Should be able to encode/decode tiles at any level of zoom', async () => {
    let tilesPerLevel, x, y, xDecoded, yDecoded, zDecoded;
    for (let z = 0; z < 30; ++z) {
        if (z === 0) {
            tilesPerLevel = 1;
        } else {
            tilesPerLevel = 2 << (z - 1);
        }

        x = 0;
        y = 0;
        let zxyDecoded = lib.quadkey.ZXYFromQuadint(lib.quadkey.quadintFromZXY(z, x, y));
        zDecoded = zxyDecoded.z;
        xDecoded = zxyDecoded.x;
        yDecoded = zxyDecoded.y;
        expect(z === zDecoded && x === xDecoded && y === yDecoded).toBeTruthy();

        if (z > 0) {
            x = tilesPerLevel / 2;
            y = tilesPerLevel / 2;
            zxyDecoded = lib.quadkey.ZXYFromQuadint(lib.quadkey.quadintFromZXY(z, x, y));
            zDecoded = zxyDecoded.z;
            xDecoded = zxyDecoded.x;
            yDecoded = zxyDecoded.y;
            expect(z === zDecoded && x === xDecoded && y === yDecoded).toBeTruthy();

            x = tilesPerLevel - 1;
            y = tilesPerLevel - 1;
            zxyDecoded = lib.quadkey.ZXYFromQuadint(lib.quadkey.quadintFromZXY(z, x, y));
            zDecoded = zxyDecoded.z;
            xDecoded = zxyDecoded.x;
            yDecoded = zxyDecoded.y;
            expect(z === zDecoded && x === xDecoded && y === yDecoded).toBeTruthy();
        }
    }
});