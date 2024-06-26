const { runQuery } = require('../../../common/test-utils');

const polygonsWkt = {
    tennisCourt: 'POLYGON ((-6.28934449565433 53.3028222364194,-6.28920842134271 53.3028715188494,-6.28904265809039 53.3027162790024,-6.28917625832361 53.3026650250877,-6.28934449565433 53.3028222364194))',
    footballPitch: 'POLYGON ((-0.016948635611556 51.5391870061221,-0.015923297482467 51.5391651657394,-0.015961923233906 51.5381692331516,-0.016994284226892 51.5381823376693,-0.016948635611556 51.5391870061221))',
    centralPark: 'POLYGON ((-73.9581734481885 40.8003760047406,-73.9493041668766 40.7969504244806,-73.9728349132144 40.7642843507669,-73.9821265412556 40.7679400942305,-73.9581734481885 40.8003760047406))',
    manhattanIsland: 'POLYGON ((-73.9277647658113 40.8765463305537,-73.9083455081116 40.8726131824587,-73.934006670072 40.8337935954031,-73.929498628106 40.7970514319678,-73.9437162989219 40.7818237174634,-73.9409421192505 40.7760467743388,-73.9714580956358 40.7413745658556,-73.9745790477661 40.7348058228905,-73.9707645507179 40.7277108519672,-73.9766596825197 40.7111529778644,-74.0127240182477 40.7001121070861,-74.0189659225084 40.7048441329741,-74.0092562936585 40.7539847340763,-73.9593210595734 40.8211985746244,-73.9478775684289 40.8393031647459,-73.9457969336754 40.8497963157552,-73.9347002149898 40.8626481615087,-73.9277647658113 40.8765463305537))',
    spain: 'POLYGON ((-8.90806736221923 41.8706635124104,-8.11181452117029 42.1601631309042,-8.1456976207894 41.7949252059901,-6.31601024135781 41.933710300506,-6.12965319345274 41.4783847414197,-7.41721097897867 37.1960149081344,-6.31601024135781 36.8714369692099,-5.94329614554767 36.1223963607846,-5.57058204973753 36.012842475776,-4.31690736383071 36.6814599426408,-1.97897349011257 36.7222089343589,-1.53849319506422 37.4116285337434,-0.572824855919773 37.5863589975998,0.155661785890951 38.7319310221496,-0.318701608776497 39.546601475132,1.23992097370226 41.1347761010052,3.25596540103892 41.8328055614838,3.28984850065802 42.4233374273265,0.189544885510054 42.6729568637547,-1.80955799201705 43.3419396565053,-3.67312847106774 43.4896126871605,-6.29906869154826 43.5264746715754,-7.85769127402702 43.7716458491458,-9.45019695612488 43.0702706652373,-8.87418426260012 42.3607766281235,-8.90806736221923 41.8706635124104))',
    africa: 'POLYGON ((-6.18681324230837 34.32975238713,10.6245368266105 36.8379847608463,11.0872345349294 33.433472073531,20.3411887013068 30.2903330071659,20.3411887013068 33.0464813781609,32.9882593953559 30.5563244246685,44.0930043950087 10.6175077622945,50.7250048809125 11.5256694933408,40.5456552978974 -2.43023717904863,38.6948644646219 -7.19320502027326,41.4710507145351 -14.3099721821406,34.8390502286313 -20.4877739075543,35.4559805063898 -25.3163707073876,32.525561687037 -26.5645756977869,31.7543988398389 -30.8908858266023,18.9530955763502 -34.6505294423347,11.8583973821275 -17.8659246687455,13.709188215403 -9.02540810631568,7.38565286837845 -1.50539755792676,8.61951342389544 3.11986341112736,-1.7140687285593 5.11960347139298,-10.9680228949367 4.35107870862103,-18.3711862280386 14.08219205561,-17.4457908114008 22.2795101913754,-10.5053251866178 29.6221985695737,-6.18681324230837 34.32975238713))'
}

const multiPolygonsWkt = {
    duckPonds: 'MULTIPOLYGON (((-0.1847365064947 51.5062187993979,-0.183896333915387 51.5065292989274,-0.182399776508484 51.5066927188826,-0.181795902467103 51.506055377743,-0.182084711791242 51.5053690003918,-0.184027610880904 51.5050421504002,-0.1847365064947 51.5054343701088,-0.184867783460218 51.5059409822358,-0.1847365064947 51.5062187993979)),((-0.175809672839494 51.5100590395608,-0.175100777225699 51.5101897654439,-0.174470647791213 51.5084085930252,-0.17326289970845 51.5072320005762,-0.172527748701551 51.5065946669799,-0.173079111956726 51.505924639997,-0.174313115432592 51.5065783249755,-0.175048266439491 51.507526151537,-0.175888439018805 51.5087190776324,-0.175993460591219 51.5095197913283,-0.175809672839494 51.5100590395608)),((-0.172081407018791 51.5065129568997,-0.172685281060172 51.5057939018759,-0.171214979046374 51.5051075205861,-0.169140802991194 51.5047479834032,-0.165701346494629 51.5044865000338,-0.162261889998064 51.5039471858456,-0.160660311018748 51.503914499932,-0.160371501694609 51.5043557577864,-0.160108947763574 51.5043884433834,-0.160135203156677 51.5046989553857,-0.16008269237047 51.5051402056439,-0.163312105722206 51.5058265864414,-0.164913684701523 51.5058756132456,-0.168353141198087 51.5058592709834,-0.169429612315333 51.5058429287153,-0.172081407018791 51.5065129568997)))',
    farmFields: 'MULTIPOLYGON (((3.9314579363239 48.7451508148407,3.93669390339958 48.747308672349,3.94436085518898 48.7418213672108,3.93949888576156 48.7395399516807,3.9314579363239 48.7451508148407)),((3.95043831697326 48.7534734689634,3.95978825817985 48.7576034595499,3.96652021584858 48.7526104429706,3.9577312711144 48.7482950906354,3.95043831697326 48.7534734689634)),((3.95286930168697 48.7319550422314,3.95754427229026 48.7336201203865,3.96380873289868 48.7249857834619,3.95894676347125 48.7235671434568,3.95286930168697 48.7319550422314)))',
    canaryIslands: 'MULTIPOLYGON (((-18.0194950057482 28.767294861495,-17.9189899416691 28.8621295769448,-17.7450388692247 28.831656407637,-17.7063830753481 28.7062841275009,-17.8455439333037 28.4584872782872,-18.0194950057482 28.767294861495)),((-16.9255360390419 28.3496802533479,-16.6974668551703 28.0021143999467,-16.4964567270123 28.0328273537469,-16.376623765995 28.3802935213973,-16.1176299470221 28.5196420808903,-16.1369578439604 28.6316671143085,-16.589230632316 28.4108979552096,-16.9255360390419 28.3496802533479)),((-17.2734381839308 28.2135145620708,-17.3198251365827 28.1964816166776,-17.3430186129086 28.1010469779639,-17.2579758663802 28.0225906758754,-17.0994871114864 28.0771750364543,-17.1110838496493 28.1658154736514,-17.2734381839308 28.2135145620708)),((-18.1354623873778 27.766357961642,-18.0388229026864 27.7526751978046,-17.9383178386074 27.8518362416617,-17.8571406714667 27.8279091042007,-17.976973632484 27.6328777264176,-18.0658819584 27.6842355964704,-18.166387022479 27.7013495231668,-18.1354623873778 27.766357961642)),((-15.7156096907061 28.1658154736514,-15.4720781892838 28.1317316716573,-15.4063633396937 28.1930747017532,-15.3522452282665 28.1555914721898,-15.3793042839801 27.8484184022801,-15.5957767296888 27.7492542381415,-15.7851901196838 27.8073959301359,-15.839308231111 27.9850478635236,-15.727206428869 28.0703535068871,-15.7156096907061 28.1658154736514)),((-14.0222131310203 28.7004147462901,-13.8678479301717 28.772072698678,-13.8194196318663 28.6499593420137,-13.9283833030535 28.2374447022957,-14.212899555598 28.1680914626501,-14.3400238386499 28.0426080438239,-14.512549651363 28.0666481420238,-14.4974158081426 28.1280595122995,-14.4035859801758 28.1093728157525,-14.2159263242421 28.2161100392333,-14.0222131310203 28.7004147462901)),((-13.8950888479685 28.8622386728752,-13.777044870849 28.8436814725666,-13.7316433411876 28.9072923672835,-13.6347867445767 28.9311364079211,-13.4531806259313 29.0158707898105,-13.4259397081345 29.2115528325736,-13.5137159988131 29.3171717181508,-13.5288498420336 29.1534159784119,-13.6408402818649 29.1322671389583,-13.7921787140694 29.0687945187246,-13.8466605496631 28.9946937003264,-13.8345534750867 28.933785407335,-13.8950888479685 28.8622386728752)))',
    southAmericanCountries: 'MULTIPOLYGON (((-51.0402348797903 3.80921001016012,-58.8887341410253 1.323353025417,-60.4201486310223 4.95439442681803,-65.3972457235128 4.19113022719449,-73.8200254184967 -8.40894552471227,-59.2715877635245 -15.7045237045925,-54.1030638597844 -25.3698807594659,-58.505880518526 -33.2068574630847,-53.9116370485348 -35.4201585439674,-47.7859790885465 -25.0234557274646,-40.1289066385611 -22.9246716416212,-38.7889189598137 -13.1090750509028,-34.5775291123217 -5.36859469737905,-50.0831008235421 -0.207943331903141,-51.0402348797903 3.80921001016012)),((-69.1527969814148 -11.502562681899,-59.5468686637489 -15.8967321056371,-57.7496304623792 -19.2636677217718,-58.431341504278 -19.497515507521,-62.0877916380992 -19.497515507521,-62.5216077556713 -22.0468385195633,-67.8513486286988 -22.6772793895194,-69.33871817466 -17.5584981509195,-69.1527969814148 -11.502562681899)),((-57.8570538894109 -20.6597445927195,-55.7073592503026 -25.7613409063218,-58.9319012089652 -31.4203489873142,-59.6484660886679 -34.4271185412807,-57.1404890097082 -36.613916268976,-63.768714146959 -41.3456024887631,-65.9184087860674 -41.3456024887631,-68.7846683048786 -52.4295321805673,-71.6509278236897 -51.7692762704576,-72.7257751432439 -49.380862225017,-71.471786603764 -42.1475262020993,-70.3969392842098 -32.7860335716503,-69.14295074473 -27.5225687782282,-67.7098209853244 -24.3005522230791,-57.8570538894109 -20.6597445927195)))'
}

describe('H3_POLYFILL should support POLYGON geographies', () => {
    test.each([
        ['tennisCourt', 15, undefined, 262],
        ['tennisCourt', 15, 'contains', 222],
        ['tennisCourt', 15, 'center', 262],
        ['tennisCourt', 15, 'intersects', 302],
        ['footballPitch', 15, undefined, 9922],
        ['footballPitch', 15, 'contains', 9669],
        ['footballPitch', 15, 'center', 9922],
        ['footballPitch', 15, 'intersects', 10150],
        ['centralPark', 12, undefined, 11506],
        ['centralPark', 12, 'contains', 11171],
        ['centralPark', 12, 'center', 11506],
        ['centralPark', 12, 'intersects', 11845],
        ['manhattanIsland', 10, undefined, 3810],
        ['manhattanIsland', 10, 'contains', 3591],
        ['manhattanIsland', 10, 'center', 3810],
        ['manhattanIsland', 10, 'intersects', 4037],
        ['spain', 6, undefined, 13344],
        ['spain', 6, 'contains', 13006],
        ['spain', 6, 'center', 13344],
        ['spain', 6, 'intersects', 13701],
        ['africa', 3, undefined, 2323],
        ['africa', 3, 'contains', 2178],
        ['africa', 3, 'center', 2323],
        ['africa', 3, 'intersects', 2470]
    ])('Called with geography POLYGON:%s, a resolution of %i in %s mode, should return %i H3 cell identifiers', async (polygonName, resolution, mode, expectedCellCount) => {
        const polygonWkt = polygonsWkt[polygonName]; // Assuming polygonsWkt is an object with WKT strings

        let query = mode === undefined ?
            `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${polygonWkt}'), ${resolution})) as cell_count` :
            `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${polygonWkt}'), ${resolution}, '${mode}')) as cell_count`;

        const rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(expectedCellCount);
    });

});


describe('H3_POLYFILL should support MULTIPOLYGON geographies', () => {
    test.each([
        ['duckPonds', 13, undefined, 4945],
        ['duckPonds', 13, 'contains', 4585],
        ['duckPonds', 13, 'center', 4945],
        ['duckPonds', 13, 'intersects', 5293],
        ['farmFields', 10, undefined, 102],
        ['farmFields', 10, 'contains', 63],
        ['farmFields', 10, 'center', 102],
        ['farmFields', 10, 'intersects', 153],
        ['canaryIslands', 7, undefined, 1312],
        ['canaryIslands', 7, 'contains', 1068],
        ['canaryIslands', 7, 'center', 1312],
        ['canaryIslands', 7, 'intersects', 1570],
        ['southAmericanCountries', 5, undefined, 49158],
        ['southAmericanCountries', 5, 'contains', 48136],
        ['southAmericanCountries', 5, 'center', 49158],
        ['southAmericanCountries', 5, 'intersects', 50354]
    ])('Called with geography MULTIPOLYGON:%s, a resolution of %i in %s mode, should return %i H3 cell identifiers', async (multiPolygonName, resolution, mode, expectedCellCount) => {
        let query;
        const polygonWkt = multiPolygonsWkt[multiPolygonName];

        if (mode === undefined) {
            query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${polygonWkt}'), ${resolution})) as cell_count`;
        } else {
            query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${polygonWkt}'), ${resolution}, '${mode}')) as cell_count`;
        }

        const rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(expectedCellCount);
    })
});

describe('Support GEOMETRYCOLLECTION containing 1 or more POLYGON Geographies', () => {
    const geometryCollection = 'GEOMETRYCOLLECTION( POLYGON((3.00 3.00, 3.20 3.40, 3.40 3.00, 3.00 3.00)), POLYGON((3.50 3.50, 3.50 3.70, 3.80 3.70, 3.80 3.50, 3.50 3.50)))';

    test.each([
        ['center', 61],
        ['contains', 36],
        ['intersects', 90]
    ])('H3_POLYFILL with mode %s should return expected cell count', async (mode, expectedCellCount) => {
        const query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${geometryCollection}'), 6, '${mode}')) as cell_count`;
        const rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(expectedCellCount);
    });
});

describe('NOT Support a GEOMETRYCOLLECTION containing 0 POLYGON Geographies. Return [].', () => {
    const geometryCollection = 'GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))';

    test.each([
        ['center', 0],
        ['contains', 0],
        ['intersects', 0]
    ])('H3_POLYFILL with mode %s should return expected empty result', async (mode, expectedCellCount) => {
        const query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${geometryCollection}'), 6, '${mode}')) as cell_count`;
        const rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(expectedCellCount);
    });
});


describe('Resolution support between 0 and 15 inclusive for H3_POLYFILL', () => {
    const testCases = [
        ['duckPonds',-1, 'contains', 0],
        ['duckPonds',16, 'center', 0],
        ['duckPonds',16, 'intersects',  0],
        ['duckPonds',999, undefined, 0],
        ['duckPonds',13, undefined, 4945]
    ];

    test.each(testCases)('For %s at resolution %i in %s mode, expected cell count is %i', async (polygonWkt, resolution, mode, expectedCellCount) => {
        let query;
        const wkt = multiPolygonsWkt[polygonWkt];

        if (mode === undefined) {
            query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${wkt}'), ${resolution})) as cell_count`;
        } else {
            query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${wkt}'), ${resolution}, '${mode}')) as cell_count`;
        }

        const rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(expectedCellCount);
    });
});

describe('H3_POLYFILL should not support POINT Geographies', () => {
    const pointWkt = 'POINT(1.111 5.555)';

    test.each([
        [undefined, 0],
        ['center', 0],
        ['contains', 0],
        ['intersects', 0]
    ])('with mode %s, should return empty array', async (mode, expectedCellCount) => {
        let query = mode === undefined ?
            `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${pointWkt}'), 6)) as cell_count` :
            `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${pointWkt}'), 6, '${mode}')) as cell_count`;

        const rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(expectedCellCount);
    });
});

describe('H3_POLYFILL should not support MULTIPOINT Geographies', () => {
    const multiPointWkt = 'MULTIPOINT(1.111 5.555, 2.222 6.666)';

    test.each([
        [undefined, 0],
        ['center', 0],
        ['contains', 0],
        ['intersects', 0]
    ])('with mode %s, should return empty array', async (mode, expectedCellCount) => {
        let query = mode === undefined ?
            `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${multiPointWkt}'), 6)) as cell_count` :
            `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${multiPointWkt}'), 6, '${mode}')) as cell_count`;

        const rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(expectedCellCount);
    });
});

describe('H3_POLYFILL should not support LINESTRING Geographies', () => {
    const lineStringWkt = 'LINESTRING(0 0, 1 1)';

    test.each([
        [undefined, 0],
        ['center', 0],
        ['contains', 0],
        ['intersects', 0]
    ])('with mode %s, should return empty array', async (mode, expectedCellCount) => {
        let query = mode === undefined ?
            `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${lineStringWkt}'), 6)) as cell_count` :
            `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${lineStringWkt}'), 6, '${mode}')) as cell_count`;

        const rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(expectedCellCount);
    });
});

describe('H3_POLYFILL should not support MULTILINESTRING Geographies', () => {
    const multiLineStringWkt = 'MULTILINESTRING((0 0, 1 1), (2 2, 3 3))';

    test.each([
        [undefined, 0],
        ['center', 0],
        ['contains', 0],
        ['intersects', 0]
    ])('with mode %s, should return empty array', async (mode, expectedCellCount) => {
        let query = mode === undefined ?
            `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${multiLineStringWkt}'), 6)) as cell_count` :
            `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${multiLineStringWkt}'), 6, '${mode}')) as cell_count`;

        const rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(expectedCellCount);
    });
});

describe('H3_POLYFILL should NOT support NULL Geography', () => {
    test('Returns []', async () => {

        let query = 'SELECT ARRAY_SIZE(H3_POLYFILL(NULL, 6, \'center\')) as cell_count'
        let rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(0)
    });
})

describe('H3_POLYFILL for Geographies crossing the Prime-Meridian multiple times', () => {
    const polygonWkt = 'POLYGON ((-16.226053271365 29.7435335822744,-13.1839184674949 35.1034853795694,9.26993365630844 26.9911259025824,-4.34724118006261 13.9534053145676,13.0363862706238 6.99995433429298,-15.9363261471869 -5.31344844327657,-19.5579151994132 0.191366916107455,-5.6510132388641 5.98590939966961,-15.6465990230088 10.6215433865193,-3.62292336961735 24.5284453470685,-16.226053271365 29.7435335822744))';
    const resolution = 3;

    test.each([
        ['center', 567],
        ['contains', 469],
        ['intersects', 667]
    ])('with mode %s, should return expected cell count', async (mode, expectedCellCount) => {
        const query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${polygonWkt}'), ${resolution}, '${mode}')) as cell_count`;
        const rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(expectedCellCount);
    });
});

describe('H3_POLYFILL for POLYGON Geographies over 180 degrees wide', () => {
    const polygonWkt = 'POLYGON((-160 -30, -160 30, 160 30, 160 -30, -160 -30))';
    const resolution = 0;

    test.each([
        ['center', 56],
        ['contains', 32],
        ['intersects', 76]
    ])('with mode %s, should return expected cell count', async (mode, expectedCellCount) => {
        const query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${polygonWkt}'), ${resolution}, '${mode}')) as cell_count`;
        const rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(expectedCellCount);
    });
});

describe('H3_POLYFILL called with a H3 cell boundary/polygon in CENTER mode at the same resolution should return only that cell ID', () => {

    test.each([
        ['8029fffffffffff', 0],
        ['81283ffffffffff', 1],
        ['822837fffffffff', 2],
        ['832834fffffffff', 3],
        ['8428347ffffffff', 4],
        ['85283463fffffff', 5],
        ['862834637ffffff', 6],
        ['872834636ffffff', 7],
        ['882834636dfffff', 8],
        ['892834636dbffff', 9],
        ['8a2834636db7fff', 10],
        ['8b2834636db5fff', 11],
        ['8c2834636db5bff', 12],
        ['8d2834636db5b3f', 13],
        ['8e2834636db5b4f', 14],
        ['8f2834636db5bac', 15]
    ])('boundary of cell with id %s at resolution level %i', async (cellId, resolution) => {
        let query = `SELECT H3_POLYFILL(H3_CELL_TO_BOUNDARY('${cellId}'), '${resolution}', 'center') as h3_cell`;
        let rows = await runQuery(query);
        expect(rows[0].H3_CELL).toEqual([cellId])
    })

})

describe('H3_POLYFILL called with a H3 cell boundary/polygon in CENTER mode as that cells resolution+1 should its 7 child cell ids. Same as calling H3_CELL_TO_CHILDREN_STRINGS.', () => {

    test.each([
        ['8029fffffffffff', 1],
        ['81283ffffffffff', 2],
        ['822837fffffffff', 3],
        ['832834fffffffff', 4],
        ['8428347ffffffff', 5],
        ['85283463fffffff', 6],
        ['862834637ffffff', 7],
        ['872834636ffffff', 8],
        ['882834636dfffff', 9],
        ['892834636dbffff', 10],
        ['8a2834636db7fff', 11],
        ['8b2834636db5fff', 12],
        ['8c2834636db5bff', 13],
        ['8d2834636db5b3f', 14],
        ['8e2834636db5b4f', 15]
    ])('boundary of cell with id %s at resolution level %i', async (cellId, resolution) => {
        let query = `SELECT ARRAY_SIZE(H3_POLYFILL(H3_CELL_TO_BOUNDARY('${cellId}'), '${resolution}', 'center')) as cell_count`;
        let rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(7)
    })
})

describe('H3_POLYFILL called with a H3 cell boundary/polygon in INTERSECTS mode at the same resolution should return 7 ids. Itself and 6 neighbours.', () => {

    test.each([
        ['8029fffffffffff', 0],
        ['81283ffffffffff', 1],
        ['822837fffffffff', 2],
        ['832834fffffffff', 3],
        ['8428347ffffffff', 4],
        ['85283463fffffff', 5],
        ['862834637ffffff', 6],
        ['872834636ffffff', 7],
        ['882834636dfffff', 8],
        ['892834636dbffff', 9],
        ['8a2834636db7fff', 10],
        ['8b2834636db5fff', 11],
        ['8c2834636db5bff', 12],
        ['8d2834636db5b3f', 13],
        ['8e2834636db5b4f', 14],
        ['8f2834636db5bac', 15]
    ])('boundary of cell with id %s at resolution level %i', async (cellId, resolution) => {
        let query = `SELECT ARRAY_SIZE(H3_POLYFILL(H3_CELL_TO_BOUNDARY('${cellId}'), '${resolution}', 'intersects')) as cell_count`;
        let rows = await runQuery(query);
        expect(rows[0].CELL_COUNT).toEqual(7)
    })

})

describe('H3_POLYFILL called with a H3 cell boundary/polygon in CONTAINS mode at the same resolution should return its own ID. H3 cells contains themselves.', () => {

    test.each([
        ['8029fffffffffff', 0],
        ['81283ffffffffff', 1],
        ['822837fffffffff', 2],
        ['832834fffffffff', 3],
        ['8428347ffffffff', 4],
        ['85283463fffffff', 5],
        ['862834637ffffff', 6],
        ['872834636ffffff', 7],
        ['882834636dfffff', 8],
        ['892834636dbffff', 9],
        ['8a2834636db7fff', 10],
        ['8b2834636db5fff', 11],
        ['8c2834636db5bff', 12],
        ['8d2834636db5b3f', 13],
        ['8e2834636db5b4f', 14],
        ['8f2834636db5bac', 15]
    ])('boundary of cell with id %s at resolution level %i', async (cellId, resolution) => {
        let query = `SELECT H3_POLYFILL(H3_CELL_TO_BOUNDARY('${cellId}'), '${resolution}', 'contains') as h3_cell`;
        let rows = await runQuery(query);
        expect(rows[0].H3_CELL).toEqual([cellId])
    })

})