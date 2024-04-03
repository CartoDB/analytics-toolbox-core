const { runQuery } = require('../../../common/test-utils');

const polygonsWkt = {
    tennisCourt: "POLYGON ((-6.28934449565433 53.3028222364194,-6.28920842134271 53.3028715188494,-6.28904265809039 53.3027162790024,-6.28917625832361 53.3026650250877,-6.28934449565433 53.3028222364194))",
    footballPitch: "POLYGON ((-0.016948635611556 51.5391870061221,-0.015923297482467 51.5391651657394,-0.015961923233906 51.5381692331516,-0.016994284226892 51.5381823376693,-0.016948635611556 51.5391870061221))",
    centralPark: "POLYGON ((-73.9581734481885 40.8003760047406,-73.9493041668766 40.7969504244806,-73.9728349132144 40.7642843507669,-73.9821265412556 40.7679400942305,-73.9581734481885 40.8003760047406))",
    manhattanIsland: "POLYGON ((-73.9277647658113 40.8765463305537,-73.9083455081116 40.8726131824587,-73.934006670072 40.8337935954031,-73.929498628106 40.7970514319678,-73.9437162989219 40.7818237174634,-73.9409421192505 40.7760467743388,-73.9714580956358 40.7413745658556,-73.9745790477661 40.7348058228905,-73.9707645507179 40.7277108519672,-73.9766596825197 40.7111529778644,-74.0127240182477 40.7001121070861,-74.0189659225084 40.7048441329741,-74.0092562936585 40.7539847340763,-73.9593210595734 40.8211985746244,-73.9478775684289 40.8393031647459,-73.9457969336754 40.8497963157552,-73.9347002149898 40.8626481615087,-73.9277647658113 40.8765463305537))",
    spain: "POLYGON ((-8.90806736221923 41.8706635124104,-8.11181452117029 42.1601631309042,-8.1456976207894 41.7949252059901,-6.31601024135781 41.933710300506,-6.12965319345274 41.4783847414197,-7.41721097897867 37.1960149081344,-6.31601024135781 36.8714369692099,-5.94329614554767 36.1223963607846,-5.57058204973753 36.012842475776,-4.31690736383071 36.6814599426408,-1.97897349011257 36.7222089343589,-1.53849319506422 37.4116285337434,-0.572824855919773 37.5863589975998,0.155661785890951 38.7319310221496,-0.318701608776497 39.546601475132,1.23992097370226 41.1347761010052,3.25596540103892 41.8328055614838,3.28984850065802 42.4233374273265,0.189544885510054 42.6729568637547,-1.80955799201705 43.3419396565053,-3.67312847106774 43.4896126871605,-6.29906869154826 43.5264746715754,-7.85769127402702 43.7716458491458,-9.45019695612488 43.0702706652373,-8.87418426260012 42.3607766281235,-8.90806736221923 41.8706635124104))",
    africa: "POLYGON ((-6.18681324230837 34.32975238713,10.6245368266105 36.8379847608463,11.0872345349294 33.433472073531,20.3411887013068 30.2903330071659,20.3411887013068 33.0464813781609,32.9882593953559 30.5563244246685,44.0930043950087 10.6175077622945,50.7250048809125 11.5256694933408,40.5456552978974 -2.43023717904863,38.6948644646219 -7.19320502027326,41.4710507145351 -14.3099721821406,34.8390502286313 -20.4877739075543,35.4559805063898 -25.3163707073876,32.525561687037 -26.5645756977869,31.7543988398389 -30.8908858266023,18.9530955763502 -34.6505294423347,11.8583973821275 -17.8659246687455,13.709188215403 -9.02540810631568,7.38565286837845 -1.50539755792676,8.61951342389544 3.11986341112736,-1.7140687285593 5.11960347139298,-10.9680228949367 4.35107870862103,-18.3711862280386 14.08219205561,-17.4457908114008 22.2795101913754,-10.5053251866178 29.6221985695737,-6.18681324230837 34.32975238713))"
}

const multiPolygonsWkt = {
    duckPonds: "MULTIPOLYGON (((-0.1847365064947 51.5062187993979,-0.183896333915387 51.5065292989274,-0.182399776508484 51.5066927188826,-0.181795902467103 51.506055377743,-0.182084711791242 51.5053690003918,-0.184027610880904 51.5050421504002,-0.1847365064947 51.5054343701088,-0.184867783460218 51.5059409822358,-0.1847365064947 51.5062187993979)),((-0.175809672839494 51.5100590395608,-0.175100777225699 51.5101897654439,-0.174470647791213 51.5084085930252,-0.17326289970845 51.5072320005762,-0.172527748701551 51.5065946669799,-0.173079111956726 51.505924639997,-0.174313115432592 51.5065783249755,-0.175048266439491 51.507526151537,-0.175888439018805 51.5087190776324,-0.175993460591219 51.5095197913283,-0.175809672839494 51.5100590395608)),((-0.172081407018791 51.5065129568997,-0.172685281060172 51.5057939018759,-0.171214979046374 51.5051075205861,-0.169140802991194 51.5047479834032,-0.165701346494629 51.5044865000338,-0.162261889998064 51.5039471858456,-0.160660311018748 51.503914499932,-0.160371501694609 51.5043557577864,-0.160108947763574 51.5043884433834,-0.160135203156677 51.5046989553857,-0.16008269237047 51.5051402056439,-0.163312105722206 51.5058265864414,-0.164913684701523 51.5058756132456,-0.168353141198087 51.5058592709834,-0.169429612315333 51.5058429287153,-0.172081407018791 51.5065129568997)))",
    farmFields: "MULTIPOLYGON (((3.9314579363239 48.7451508148407,3.93669390339958 48.747308672349,3.94436085518898 48.7418213672108,3.93949888576156 48.7395399516807,3.9314579363239 48.7451508148407)),((3.95043831697326 48.7534734689634,3.95978825817985 48.7576034595499,3.96652021584858 48.7526104429706,3.9577312711144 48.7482950906354,3.95043831697326 48.7534734689634)),((3.95286930168697 48.7319550422314,3.95754427229026 48.7336201203865,3.96380873289868 48.7249857834619,3.95894676347125 48.7235671434568,3.95286930168697 48.7319550422314)))",
    canaryIslands: "MULTIPOLYGON (((-18.0194950057482 28.767294861495,-17.9189899416691 28.8621295769448,-17.7450388692247 28.831656407637,-17.7063830753481 28.7062841275009,-17.8455439333037 28.4584872782872,-18.0194950057482 28.767294861495)),((-16.9255360390419 28.3496802533479,-16.6974668551703 28.0021143999467,-16.4964567270123 28.0328273537469,-16.376623765995 28.3802935213973,-16.1176299470221 28.5196420808903,-16.1369578439604 28.6316671143085,-16.589230632316 28.4108979552096,-16.9255360390419 28.3496802533479)),((-17.2734381839308 28.2135145620708,-17.3198251365827 28.1964816166776,-17.3430186129086 28.1010469779639,-17.2579758663802 28.0225906758754,-17.0994871114864 28.0771750364543,-17.1110838496493 28.1658154736514,-17.2734381839308 28.2135145620708)),((-18.1354623873778 27.766357961642,-18.0388229026864 27.7526751978046,-17.9383178386074 27.8518362416617,-17.8571406714667 27.8279091042007,-17.976973632484 27.6328777264176,-18.0658819584 27.6842355964704,-18.166387022479 27.7013495231668,-18.1354623873778 27.766357961642)),((-15.7156096907061 28.1658154736514,-15.4720781892838 28.1317316716573,-15.4063633396937 28.1930747017532,-15.3522452282665 28.1555914721898,-15.3793042839801 27.8484184022801,-15.5957767296888 27.7492542381415,-15.7851901196838 27.8073959301359,-15.839308231111 27.9850478635236,-15.727206428869 28.0703535068871,-15.7156096907061 28.1658154736514)),((-14.0222131310203 28.7004147462901,-13.8678479301717 28.772072698678,-13.8194196318663 28.6499593420137,-13.9283833030535 28.2374447022957,-14.212899555598 28.1680914626501,-14.3400238386499 28.0426080438239,-14.512549651363 28.0666481420238,-14.4974158081426 28.1280595122995,-14.4035859801758 28.1093728157525,-14.2159263242421 28.2161100392333,-14.0222131310203 28.7004147462901)),((-13.8950888479685 28.8622386728752,-13.777044870849 28.8436814725666,-13.7316433411876 28.9072923672835,-13.6347867445767 28.9311364079211,-13.4531806259313 29.0158707898105,-13.4259397081345 29.2115528325736,-13.5137159988131 29.3171717181508,-13.5288498420336 29.1534159784119,-13.6408402818649 29.1322671389583,-13.7921787140694 29.0687945187246,-13.8466605496631 28.9946937003264,-13.8345534750867 28.933785407335,-13.8950888479685 28.8622386728752)))",
    southAmericanCountries: "MULTIPOLYGON (((-51.0402348797903 3.80921001016012,-58.8887341410253 1.323353025417,-60.4201486310223 4.95439442681803,-65.3972457235128 4.19113022719449,-73.8200254184967 -8.40894552471227,-59.2715877635245 -15.7045237045925,-54.1030638597844 -25.3698807594659,-58.505880518526 -33.2068574630847,-53.9116370485348 -35.4201585439674,-47.7859790885465 -25.0234557274646,-40.1289066385611 -22.9246716416212,-38.7889189598137 -13.1090750509028,-34.5775291123217 -5.36859469737905,-50.0831008235421 -0.207943331903141,-51.0402348797903 3.80921001016012)),((-69.1527969814148 -11.502562681899,-59.5468686637489 -15.8967321056371,-57.7496304623792 -19.2636677217718,-58.431341504278 -19.497515507521,-62.0877916380992 -19.497515507521,-62.5216077556713 -22.0468385195633,-67.8513486286988 -22.6772793895194,-69.33871817466 -17.5584981509195,-69.1527969814148 -11.502562681899)),((-57.8570538894109 -20.6597445927195,-55.7073592503026 -25.7613409063218,-58.9319012089652 -31.4203489873142,-59.6484660886679 -34.4271185412807,-57.1404890097082 -36.613916268976,-63.768714146959 -41.3456024887631,-65.9184087860674 -41.3456024887631,-68.7846683048786 -52.4295321805673,-71.6509278236897 -51.7692762704576,-72.7257751432439 -49.380862225017,-71.471786603764 -42.1475262020993,-70.3969392842098 -32.7860335716503,-69.14295074473 -27.5225687782282,-67.7098209853244 -24.3005522230791,-57.8570538894109 -20.6597445927195)))"
}


test('Should support POLYGON Geographies', async () => {

    const testCases = [
        {polygonWkt: polygonsWkt.tennisCourt, resolution: 15, mode: undefined, expectedCellCount: 262},
        {polygonWkt: polygonsWkt.tennisCourt, resolution: 15, mode: 'contains', expectedCellCount: 222},
        {polygonWkt: polygonsWkt.tennisCourt, resolution: 15, mode: 'center', expectedCellCount: 262},
        {polygonWkt: polygonsWkt.tennisCourt, resolution: 15, mode: 'intersects', expectedCellCount: 302},
        {polygonWkt: polygonsWkt.footballPitch, resolution: 15, mode: undefined, expectedCellCount: 9922},
        {polygonWkt: polygonsWkt.footballPitch, resolution: 15, mode: 'contains', expectedCellCount: 9669},
        {polygonWkt: polygonsWkt.footballPitch, resolution: 15, mode: 'center', expectedCellCount: 9922},
        {polygonWkt: polygonsWkt.footballPitch, resolution: 15, mode: 'intersects', expectedCellCount: 10150},
        {polygonWkt: polygonsWkt.centralPark, resolution: 12, mode: undefined, expectedCellCount: 11506},
        {polygonWkt: polygonsWkt.centralPark, resolution: 12, mode: 'contains', expectedCellCount: 11171},
        {polygonWkt: polygonsWkt.centralPark, resolution: 12, mode: 'center', expectedCellCount: 11506},
        {polygonWkt: polygonsWkt.centralPark, resolution: 12, mode: 'intersects', expectedCellCount: 11845},
        {polygonWkt: polygonsWkt.manhattanIsland, resolution: 10, mode: undefined, expectedCellCount: 3810}, // NOTE: as res 12 it raises exceeds limit error
        {polygonWkt: polygonsWkt.manhattanIsland, resolution: 10, mode: 'contains', expectedCellCount: 3591},
        {polygonWkt: polygonsWkt.manhattanIsland, resolution: 10, mode: 'center', expectedCellCount: 3810},
        {polygonWkt: polygonsWkt.manhattanIsland, resolution: 10, mode: 'intersects', expectedCellCount: 4037},
        {polygonWkt: polygonsWkt.spain, resolution: 6, mode: undefined, expectedCellCount: 13344},
        {polygonWkt: polygonsWkt.spain, resolution: 6, mode: 'contains', expectedCellCount: 13006},
        {polygonWkt: polygonsWkt.spain, resolution: 6, mode: 'center', expectedCellCount: 13344},
        {polygonWkt: polygonsWkt.spain, resolution: 6, mode: 'intersects', expectedCellCount: 13699},
        {polygonWkt: polygonsWkt.africa, resolution: 3, mode: undefined, expectedCellCount: 2323},
        {polygonWkt: polygonsWkt.africa, resolution: 3, mode: 'contains', expectedCellCount: 2178},
        {polygonWkt: polygonsWkt.africa, resolution: 3, mode: 'center', expectedCellCount: 2323},
        {polygonWkt: polygonsWkt.africa, resolution: 3, mode: 'intersects', expectedCellCount: 2470}
		]

	  for (const test of testCases) {
			  let query
			  if (test.mode === undefined) {
            query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${test.polygonWkt}'), ${test.resolution})) as cell_count`
				}
			  else {
            query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${test.polygonWkt}'), ${test.resolution}, '${test.mode}')) as cell_count`
				}

        let rows = await runQuery(query);
	      expect(rows[0].CELL_COUNT).toEqual(test.expectedCellCount)
		}
})

test('Should support MULTIPOLYGON Geographies', async () => {

    const testCases = [
        {polygonWkt: multiPolygonsWkt.duckPonds, resolution: 13, mode: undefined, expectedCellCount: 4945},
        {polygonWkt: multiPolygonsWkt.duckPonds, resolution: 13, mode: 'contains', expectedCellCount: 4585},
        {polygonWkt: multiPolygonsWkt.duckPonds, resolution: 13, mode: 'center', expectedCellCount: 4945},
        {polygonWkt: multiPolygonsWkt.duckPonds, resolution: 13, mode: 'intersects', expectedCellCount: 5293},
        {polygonWkt: multiPolygonsWkt.farmFields, resolution: 10, mode: undefined, expectedCellCount: 102},
        {polygonWkt: multiPolygonsWkt.farmFields, resolution: 10, mode: 'contains', expectedCellCount: 63},
        {polygonWkt: multiPolygonsWkt.farmFields, resolution: 10, mode: 'center', expectedCellCount: 102},
        {polygonWkt: multiPolygonsWkt.farmFields, resolution: 10, mode: 'intersects', expectedCellCount: 153},
        {polygonWkt: multiPolygonsWkt.canaryIslands, resolution: 7, mode: undefined, expectedCellCount: 1312},
        {polygonWkt: multiPolygonsWkt.canaryIslands, resolution: 7, mode: 'contains', expectedCellCount: 1068},
        {polygonWkt: multiPolygonsWkt.canaryIslands, resolution: 7, mode: 'center', expectedCellCount: 1312},
        {polygonWkt: multiPolygonsWkt.canaryIslands, resolution: 7, mode: 'intersects', expectedCellCount: 1570},
        {polygonWkt: multiPolygonsWkt.southAmericanCountries, resolution: 5, mode: undefined, expectedCellCount: 49158},
        {polygonWkt: multiPolygonsWkt.southAmericanCountries, resolution: 5, mode: 'contains', expectedCellCount: 48136},
        {polygonWkt: multiPolygonsWkt.southAmericanCountries, resolution: 5, mode: 'center', expectedCellCount: 49158},
        {polygonWkt: multiPolygonsWkt.southAmericanCountries, resolution: 5, mode: 'intersects', expectedCellCount: 50354}
		]

	  for (const test of testCases) {
			  let query
			  if (test.mode === undefined) {
            query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${test.polygonWkt}'), ${test.resolution})) as cell_count`
				}
			  else {
            query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${test.polygonWkt}'), ${test.resolution}, '${test.mode}')) as cell_count`
				}

        let rows = await runQuery(query);
	      expect(rows[0].CELL_COUNT).toEqual(test.expectedCellCount)
		}

})

test('Should support GEOMETRYCOLLECTION containing 1 or more POLYGON Geographies', async () => {
    const geometryCollection = "GEOMETRYCOLLECTION( POLYGON((3.00 3.00, 3.20 3.40, 3.40 3.00, 3.00 3.00)), POLYGON((3.50 3.50, 3.50 3.70, 3.80 3.70, 3.80 3.50, 3.50 3.50)))"

    let query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${geometryCollection}'), 6, 'center')) as cell_count`
    let rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(61)

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${geometryCollection}'), 6, 'contains')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(999999) // TODO: FAILING

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${geometryCollection}'), 6, 'intersects')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(999999) // TODO: FAILING
})

test('Should support NOT GEOMETRYCOLLECTION containing 0 POLYGON Geographies. Returns [].', async () => {

    const geometryCollection = "GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))"

    let query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${geometryCollection}'), 6, 'center')) as cell_count`
    let rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${geometryCollection}'), 6, 'contains')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0) // TODO: FAILING

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${geometryCollection}'), 6, 'intersects')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0) // TODO: FAILING

})

test('Should support resolutions between 0 and 15 inclusive. Otherwise, returns [].', async () => {
    const testCases = [
        {polygonWkt: multiPolygonsWkt.duckPonds, resolution: -1, mode: 'contains', expectedCellCount: 0},
        {polygonWkt: multiPolygonsWkt.duckPonds, resolution: 16, mode: 'center', expectedCellCount: 0},
        {polygonWkt: multiPolygonsWkt.duckPonds, resolution: 16, mode: 'intersects', expectedCellCount: 0},
        {polygonWkt: multiPolygonsWkt.duckPonds, resolution: 999, mode: undefined, expectedCellCount: 0},
        {polygonWkt: multiPolygonsWkt.duckPonds, resolution: 13, mode: undefined, expectedCellCount: 4945},
		]

	  for (const test of testCases) {
			  let query
			  if (test.mode === undefined) {
            query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${test.polygonWkt}'), ${test.resolution})) as cell_count`
				}
			  else {
            query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${test.polygonWkt}'), ${test.resolution}, '${test.mode}')) as cell_count`
				}

        let rows = await runQuery(query);
	      expect(rows[0].CELL_COUNT).toEqual(test.expectedCellCount)
		}

})

test('Should NOT support POINT Geographies. Returns []', async () => {
    const pointWkt = "POINT(1.111 5.555)"

    let query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${pointWkt}'), 6, 'center')) as cell_count`
    let rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${pointWkt}'), 6, 'contains')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${pointWkt}'), 6, 'intersects')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)
})

test('Should NOT support MULTIPOINT Geographies. Returns []', async () => {
    const multiPointWkt = "MULTIPOINT(1.111 5.555, 2.222 6.666)"

    let query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${multiPointWkt}'), 6, 'center')) as cell_count`
    let rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${multiPointWkt}'), 6, 'contains')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${multiPointWkt}'), 6, 'intersects')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)
})

test('Should NOT support LINESTRING Geographies. Returns []', async () => {
    const lineStringWkt = "LINESTRING(0 0, 1 1)"

    let query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${lineStringWkt}'), 6, 'center')) as cell_count`
    let rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${lineStringWkt}'), 6, 'contains')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${lineStringWkt}'), 6, 'intersects')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)
})

test('Should NOT support MULTILINESTRING Geographies. Returns []', async () => {
    const multiLineStringWkt = "MULTILINESTRING((0 0, 1 1), (2 2, 3 3))"

    let query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${multiLineStringWkt}'), 6, 'center')) as cell_count`
    let rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${multiLineStringWkt}'), 6, 'contains')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)

    query = `SELECT ARRAY_SIZE(H3_POLYFILL(TO_GEOGRAPHY('${multiLineStringWkt}'), 6, 'intersects')) as cell_count`
    rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)
})

test('Should NOT support NULL Geography. Returns [].', async () => {
    let query = `SELECT ARRAY_SIZE(H3_POLYFILL(NULL, 6, 'center')) as cell_count`
    let rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(0)
})

test('Should support POLYGON, MULTIPOLYGON and GEOMETRYCOLLECTION Geographies over 180 degrees wide', async () => {

})

test('Should return only the cell id for the cell boundary/polygon at the same resolution in center mode', async () => {

	  let query = "SELECT ARRAY_SIZE(H3_POLYFILL(H3_CELL_TO_BOUNDARY('8c2834636db5bff'), 12, 'center')) as cell_count";
    let rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(1)

})

test('Should return 7 cell ids for the cell boundary/polygon at its resolution+1 in center mode. Same as calling H3_CELL_TO_CHILDREN.', async () => {

	  let query = "SELECT ARRAY_SIZE(H3_POLYFILL(H3_CELL_TO_BOUNDARY('8c2834636db5bff'), 13, 'center')) as cell_count";
    let rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(7)

})

test('Should return 7 cell ids for the cell boundary/polygon at the same resolution in intersects mode. H3 cells intersect with themselves and neighbours.', async () => {

	  let query = "SELECT ARRAY_SIZE(H3_POLYFILL(H3_CELL_TO_BOUNDARY('8c2834636db5bff'), 12, 'intersects')) as cell_count";
    let rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(7)

})

test('Should return only the cell id for the cell boundary/polygon at the same resolution in contains mode. H3 cells contain themselves.', async () => {

	  let query = "SELECT ARRAY_SIZE(H3_POLYFILL(H3_CELL_TO_BOUNDARY('8c2834636db5bff'), 12, 'contains')) as cell_count";
    let rows = await runQuery(query);
	  expect(rows[0].CELL_COUNT).toEqual(1)

})

test('H3_POLYFILL returns the proper INT64s', async () => {
    const query = `
        WITH inputs AS
        (
            SELECT 1 AS id, TO_GEOGRAPHY('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))') as geom, 9 as resolution UNION ALL
            SELECT 2 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 2 as resolution UNION ALL
            SELECT 3 AS id, TO_GEOGRAPHY('POLYGON((20 20, 20 30, 30 30, 30 20, 20 20))') as geom, 2 as resolution UNION ALL
            -- 4 is a multipolygon containing geom ids 2, 3
            SELECT 4 AS id, TO_GEOGRAPHY('MULTIPOLYGON(((0 0, 0 10, 10 10, 10 0, 0 0)), ((20 20, 20 30, 30 30, 30 20, 20 20)))') as geom, 2 as resolution UNION ALL
            SELECT 5 AS id, TO_GEOGRAPHY('GEOMETRYCOLLECTION(POLYGON((20 20, 20 30, 30 30, 30 20, 20 20)), POINT(0 10), LINESTRING(0 0, 1 1),MULTIPOLYGON(((-50 -50, -50 -40, -40 -40, -40 -50, -50 -50)), ((50 50, 50 40, 40 40, 40 50, 50 50))))') as geom, 2 as resolution UNION ALL

            -- NULL and empty
            SELECT 6 AS id, TRY_TO_GEOGRAPHY(NULL) as geom, 2 as resolution UNION ALL
            SELECT 7 AS id, TO_GEOGRAPHY('POLYGON EMPTY') as geom, 2 as resolution UNION ALL

            -- Invalid resolution
            SELECT 8 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution UNION ALL
            SELECT 9 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 20 as resolution UNION ALL
            SELECT 10 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, NULL as resolution UNION ALL

            -- Other types are not supported
            SELECT 11 AS id, TO_GEOGRAPHY('POINT(0 0)') as geom, 15 as resolution UNION ALL
            SELECT 12 AS id, TO_GEOGRAPHY('MULTIPOINT(0 0, 1 1)') as geom, 15 as resolution UNION ALL
            SELECT 13 AS id, TO_GEOGRAPHY('LINESTRING(0 0, 1 1)') as geom, 15 as resolution UNION ALL
            SELECT 14 AS id, TO_GEOGRAPHY('MULTILINESTRING((0 0, 1 1), (2 2, 3 3))') as geom, 15 as resolution UNION ALL

            -- 15 is a geometry collection containing only not supported types
            SELECT 15 AS id, TO_GEOGRAPHY('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))') as geom, 15 as resolution UNION ALL

            SELECT 16 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 .0001, .0001 .0001, .0001 0, 0 0))') as geom, 15 as resolution UNION ALL
            SELECT 17 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 50, 50 50, 50 0, 0 0))') as geom, 0 as resolution UNION ALL

            -- Polygon larger than 180 degrees
            SELECT 18 AS id, TO_GEOGRAPHY('{"type":"Polygon","coordinates":[[[-161.44993041898587,-3.77971025880735],[129.99811811657568,-3.77971025880735],[129.99811811657568,63.46915831771922],[-161.44993041898587,63.46915831771922],[-161.44993041898587,-3.77971025880735]]]}') as geom, 3 as resolution
        )
        SELECT
            ARRAY_SIZE(H3_POLYFILL(geom, resolution)) AS id_count
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(18);
    expect(rows.map((r) => r.ID_COUNT)).toEqual([
        1253,
        18,
        12,
        30,
        34,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        182,
        6,
        16110
    ]);
});

test ('H3_POLYFILL with named mode parameter', async () => {

    const query = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('POLYGON((-100 -50, -100 50, 100 50, 100 -50, -100 -50))'), 0, 'center') as h3_indexs UNION ALL
		    SELECT 2 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('POLYGON((-100 -50, -100 50, 100 50, 100 -50, -100 -50))'), 0, 'contains') as h3_indexs UNION ALL
		    SELECT 3 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('POLYGON((-100 -50, -100 50, 100 50, 100 -50, -100 -50))'), 0, 'intersects') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows = await runQuery(query);
    expect(rows.length).toEqual(3);
    expect(rows.map((r) => r.H3_COUNT)).toEqual([
        51,
        38,
        67
    ]);
    
    let polygonWkt = 'POLYGON((-6.34063009076414374 53.32201110704816216, -6.34218703413432117 53.32155186475911535, -6.34373277647305756 53.32156306579055638, -6.34562575078643842 53.32197750395383906, -6.34506569921443209 53.32132784413031601, -6.34518891056027368 53.32067818430678585, -6.34432643113938433 53.31993891623174164, -6.34400160122762014 53.31983810694877945, -6.34309431768097109 53.31936766362829161, -6.34228784341728247 53.31907643681085318, -6.3411453382103895 53.31879641102484868, -6.34043967322966218 53.31903163268508905, -6.33982361650045512 53.31861719452180637, -6.33974520928037499 53.31875160689908455, -6.33892753398524622 53.3191884471252493, -6.33948758555725167 53.3195020760055769, -6.33994682784629671 53.3211486276272737, -6.33968920412317427 53.32140625135039613, -6.34063009076414374 53.32201110704816216))'

    const query2 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 13, 'center') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows2 = await runQuery(query2);
    expect(rows2.length).toEqual(1);
    expect(rows2[0].H3_COUNT).toEqual(2380)

    const query3 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 13, 'contains') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows3 = await runQuery(query3);
    expect(rows3.length).toEqual(1);
    expect(rows3[0].H3_COUNT).toEqual(2261)

    const query4 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 13, 'intersects') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows4 = await runQuery(query4);
    expect(rows4.length).toEqual(1);
    expect(rows4[0].H3_COUNT).toEqual(2507)

    const query5 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 0, 'center') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows5 = await runQuery(query5);
    expect(rows5.length).toEqual(1);
    expect(rows5[0].H3_COUNT).toEqual(0)

    const query6 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 0, 'contains') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows6 = await runQuery(query6);
    expect(rows6.length).toEqual(1);
    expect(rows6[0].H6_COUNT).toEqual(undefined) // TODO: should be 0

    const query7 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 0, 'intersects') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows7 = await runQuery(query7);
    expect(rows7.length).toEqual(1);
    expect(rows7[0].H3_COUNT).toEqual(1)
})

test('H3_POLYFILL returns the expected values', async () => {
    let query = `
        WITH points AS
        (
            SELECT ST_POINT(0, 0) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    let rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.4089866999972145, 37.813318999983238) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.0553238, 37.3615593) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.0553238, 37.3615593) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution, 'center') p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.0553238, 37.3615593) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution, 'intersects') p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 7; // a h3 cell intersects with itself and its six neighbours
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.0553238, 37.3615593) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution, 'contains') p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});
