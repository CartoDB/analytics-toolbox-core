const quadkeyLib = require('../build/quadkey');

function sortByKey (list, key) {
    return list.sort((a, b) => (a[key] > b[key]) ? 1 : -1);
}

// TODO: refactor tests

test('quadkey library defined', () => {
    expect(quadkeyLib.bbox).toBeDefined();
    expect(quadkeyLib.kRing).toBeDefined();
    expect(quadkeyLib.kRingDistances).toBeDefined();
    expect(quadkeyLib.sibling).toBeDefined();
    expect(quadkeyLib.toChildren).toBeDefined();
    expect(quadkeyLib.quadkeyFromQuadint).toBeDefined();
    expect(quadkeyLib.quadintFromQuadkey).toBeDefined();
    expect(quadkeyLib.quadintFromLocation).toBeDefined();
    expect(quadkeyLib.quadintToGeoJSON).toBeDefined();
    expect(quadkeyLib.geojsonToQuadints).toBeDefined();
    expect(quadkeyLib.ZXYFromQuadint).toBeDefined();
});

it('bbox should work', async () => {
    expect(quadkeyLib.bbox(162)).toEqual([-90, 0, 0, 66.51326044311186]);
    expect(quadkeyLib.bbox(12070922)).toEqual([-45, 44.840290651397986, -44.6484375, 45.08903556483103]);
    expect(quadkeyLib.bbox(791040491538)).toEqual([-45, 44.99976701918129, -44.998626708984375, 45.00073807829068]);
    expect(quadkeyLib.bbox(12960460429066265n)).toEqual([-45, 44.999994612636684, -44.99998927116394, 45.00000219906962]);
});

test('toParent should work at any level of zoom', () => {
    let z, lat, lng;
    for (z = 1; z < 30; ++z) {
        for (lat = -90; lat <= 90; lat = lat + 15) {
            for (lng = -180; lng <= 180; lng = lng + 15) {
                const quadint = quadkeyLib.quadintFromLocation(lng, lat, z);
                const currentParent = quadkeyLib.quadintFromLocation(lng, lat, z - 1);
                expect(currentParent).toEqual(quadkeyLib.toParent(quadint, z - 1));
            }
        }
    }
    for (z = 5; z < 30; ++z) {
        for (lat = -90; lat <= 90; lat = lat + 15) {
            for (lng = -180; lng <= 180; lng = lng + 15) {
                const quadint = quadkeyLib.quadintFromLocation(lng, lat, z);
                const currentParent = quadkeyLib.quadintFromLocation(lng, lat, z - 5);
                expect(currentParent).toEqual(quadkeyLib.toParent(quadint, z - 5));
            }
        }
    }
    for (z = 10; z < 30; ++z) {
        for (lat = -90; lat <= 90; lat = lat + 15) {
            for (lng = -180; lng <= 180; lng = lng + 15) {
                const quadint = quadkeyLib.quadintFromLocation(lng, lat, z);
                const currentParent = quadkeyLib.quadintFromLocation(lng, lat, z - 10);
                expect(currentParent).toEqual(quadkeyLib.toParent(quadint, z - 10));
            }
        }
    }
});

test('toChildren should work at any level of zoom', () => {
    let z, lat, lng;
    for (z = 0; z < 29; ++z) {
        for (lat = 90; lat <= 90; lat = lat + 15) {
            for (lng = -180; lng <= 180; lng = lng + 15) {
                const quadint = quadkeyLib.quadintFromLocation(lng, lat, z);
                const childs = quadkeyLib.toChildren(quadint, z + 1);
                childs.forEach((element) => {
                    expect(quadkeyLib.toParent(element, z)).toEqual(quadint);
                });
            }
        }
    }

    for (z = 0; z < 25; ++z) {
        for (lat = 90; lat <= 90; lat = lat + 15) {
            for (lng = -180; lng <= 180; lng = lng + 15) {
                const quadint = quadkeyLib.quadintFromLocation(lng, lat, z);
                const childs = quadkeyLib.toChildren(quadint, z + 5);
                childs.forEach((element) => {
                    expect(quadkeyLib.toParent(element, z)).toEqual(quadint);
                });
            }
        }
    }
});

test('Sibling should work at any level of zoom', async () => {
    let z, lat, lng;
    for (z = 0; z < 29; ++z) {
        for (lat = -90; lat <= 90; lat = lat + 15) {
            for (lng = -180; lng <= 180; lng = lng + 15) {
                const quadint = quadkeyLib.quadintFromLocation(lng, lat, z);
                let siblingQuadint = quadkeyLib.sibling(quadint, 'right');
                siblingQuadint = quadkeyLib.sibling(siblingQuadint, 'up');
                siblingQuadint = quadkeyLib.sibling(siblingQuadint, 'left');
                siblingQuadint = quadkeyLib.sibling(siblingQuadint, 'down');
                expect(siblingQuadint).toEqual(quadint);
            }
        }
    }
});

test('kRing should work', async () => {
    expect(quadkeyLib.kRing(162, 0).sort().map(String)).toEqual([
        '162'
    ]);
    expect(quadkeyLib.kRing(162, 1).sort().map(String)).toEqual([
        '130', '162', '194', '2', '258', '290', '322', '34', '66'
    ]);
    expect(quadkeyLib.kRing(12070922, 1).sort().map(String)).toEqual([
        '12038122', '12038154', '12038186', '12070890', '12070922', '12070954', '12103658', '12103690', '12103722'
    ]);
    expect(quadkeyLib.kRing(791040491538, 1).sort().map(String)).toEqual([
        '791032102898', '791032102930', '791032102962', '791040491506', '791040491538', '791040491570', '791048880114', '791048880146', '791048880178'
    ]);
    expect(quadkeyLib.kRing(12960460429066265n, 1).sort().map(String)).toEqual([
        '12960459355324409', '12960459355324441', '12960459355324473', '12960460429066233', '12960460429066265', '12960460429066297', '12960461502808057', '12960461502808089', '12960461502808121'
    ]);
    expect(quadkeyLib.kRing(12070922, 2).sort().map(String)).toEqual([
        '12005322', '12005354', '12005386', '12005418', '12005450', '12038090', '12038122', '12038154', '12038186', '12038218', '12070858', '12070890', '12070922', '12070954', '12070986', '12103626', '12103658', '12103690', '12103722', '12103754', '12136394', '12136426', '12136458', '12136490', '12136522'
    ]);
    expect(quadkeyLib.kRing(791040491538, 3).sort().map(String)).toEqual([
        '791015325618', '791015325650', '791015325682', '791015325714', '791015325746', '791015325778', '791015325810', '791023714226', '791023714258', '791023714290', '791023714322', '791023714354', '791023714386', '791023714418', '791032102834', '791032102866', '791032102898', '791032102930', '791032102962', '791032102994', '791032103026', '791040491442', '791040491474', '791040491506', '791040491538', '791040491570', '791040491602', '791040491634', '791048880050', '791048880082', '791048880114', '791048880146', '791048880178', '791048880210', '791048880242', '791057268658', '791057268690', '791057268722', '791057268754', '791057268786', '791057268818', '791057268850', '791065657266', '791065657298', '791065657330', '791065657362', '791065657394', '791065657426', '791065657458'
    ]);
});

test('kRingDistances should work', async () => {
    expect(sortByKey(quadkeyLib.kRingDistances(162, 0),'index')).toEqual(sortByKey([
        { index: '162', distance: 0 }
    ],'index'));
    expect(sortByKey(quadkeyLib.kRingDistances(162, 1),'index')).toEqual(sortByKey([
        { index: '162', distance: 0 }, { index: '130', distance: 1 }, { index: '194', distance: 1 }, { index: '2', distance: 1 }, { index: '258', distance: 1 }, { index: '290', distance: 1 }, { index: '322', distance: 1 }, { index: '34', distance: 1 }, { index: '66', distance: 1 }
    ],'index'));
    expect(sortByKey(quadkeyLib.kRingDistances(12070922, 1),'index')).toEqual(sortByKey([
        { index: '12070922', distance: 0 }, { index: '12038122', distance: 1 }, { index: '12038154', distance: 1 }, { index: '12038186', distance: 1 }, { index: '12070890', distance: 1 }, { index: '12070954', distance: 1 }, { index: '12103658', distance: 1 }, { index: '12103690', distance: 1 }, { index: '12103722', distance: 1 }
    ],'index'));
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
        let zxyDecoded = quadkeyLib.ZXYFromQuadint(quadkeyLib.quadintFromQuadkey(quadkeyLib.quadkeyFromQuadint(quadkeyLib.quadintFromZXY(z, x, y))));
        zDecoded = zxyDecoded.z;
        xDecoded = zxyDecoded.x;
        yDecoded = zxyDecoded.y;
        expect(z === zDecoded && x === xDecoded && y === yDecoded).toBeTruthy();

        if (z > 0) {
            x = tilesPerLevel / 2;
            y = tilesPerLevel / 2;
            zxyDecoded = quadkeyLib.ZXYFromQuadint(quadkeyLib.quadintFromQuadkey(quadkeyLib.quadkeyFromQuadint(quadkeyLib.quadintFromZXY(z, x, y))));
            zDecoded = zxyDecoded.z;
            xDecoded = zxyDecoded.x;
            yDecoded = zxyDecoded.y;
            expect(z === zDecoded && x === xDecoded && y === yDecoded).toBeTruthy();

            x = tilesPerLevel - 1;
            y = tilesPerLevel - 1;
            zxyDecoded = quadkeyLib.ZXYFromQuadint(quadkeyLib.quadintFromQuadkey(quadkeyLib.quadkeyFromQuadint(quadkeyLib.quadintFromZXY(z, x, y))));
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
        let zxyDecoded = quadkeyLib.ZXYFromQuadint(quadkeyLib.quadintFromZXY(z, x, y));
        zDecoded = zxyDecoded.z;
        xDecoded = zxyDecoded.x;
        yDecoded = zxyDecoded.y;
        expect(z === zDecoded && x === xDecoded && y === yDecoded).toBeTruthy();

        if (z > 0) {
            x = tilesPerLevel / 2;
            y = tilesPerLevel / 2;
            zxyDecoded = quadkeyLib.ZXYFromQuadint(quadkeyLib.quadintFromZXY(z, x, y));
            zDecoded = zxyDecoded.z;
            xDecoded = zxyDecoded.x;
            yDecoded = zxyDecoded.y;
            expect(z === zDecoded && x === xDecoded && y === yDecoded).toBeTruthy();

            x = tilesPerLevel - 1;
            y = tilesPerLevel - 1;
            zxyDecoded = quadkeyLib.ZXYFromQuadint(quadkeyLib.quadintFromZXY(z, x, y));
            zDecoded = zxyDecoded.z;
            xDecoded = zxyDecoded.x;
            yDecoded = zxyDecoded.y;
            expect(z === zDecoded && x === xDecoded && y === yDecoded).toBeTruthy();
        }
    }
});