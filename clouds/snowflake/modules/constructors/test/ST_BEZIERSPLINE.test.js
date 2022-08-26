const { runQuery } = require('../../../common/test-utils');

test('ST_BEZIERSPLINE should work', async () => {
    const query = `
        SELECT ST_BEZIERSPLINE(ST_GEOGFROMTEXT('LINESTRING (121.025390625 -22.91792293614603, 130.6494140625 -19.394067895396613, 138.33984375 -25.681137335685307, 138.3837890625 -32.026706293336126)'), 100, 0.85) as bezierspline1,
               ST_BEZIERSPLINE(ST_GEOGFROMTEXT('LINESTRING (-6 -0.5,-3 0.5,0 -0.5,3 0.5, 6 -0.5,9 0.5)'), 60, 0.85) as bezierspline2
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].BEZIERSPLINE1)).toEqual('{"coordinates":[[121.025390625,-22.91792293614603],[122.40878796386718,-22.04579264902266],[125.672291015625,-20.380801787862705],[129.4858663330078,-19.350050352981388],[132.704296875,-20.01569558887108],[135.25804138183594,-21.75113289066844],[137.26212890625,-24.05282839437402],[138.7404580078125,-26.51113113177313],[139.065328125,-29.074453813709248],[138.68492871093753,-31.163421738140798]],"type":"LineString"}');
    expect(JSON.stringify(rows[0].BEZIERSPLINE2)).toEqual('{"coordinates":[[-6,-0.5],[-3.6649305555555554,0.4259259259259258],[-1.0611111111111116,-0.24074074074074053],[1.5,0],[4.06111111111111,0.24074074074074117],[6.664930555555557,-0.42592592592592565],[9,0.5]],"type":"LineString"}');
});

test('ST_BEZIERSPLINE should return NULL if any NULL mandatory argument', async () => {
    const query = `
        SELECT ST_BEZIERSPLINE(NULL, 10000, 0.9) as bezierspline1,
        ST_BEZIERSPLINE(ST_GEOGFROMTEXT('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), NULL, 0.9) as bezierspline2,
        ST_BEZIERSPLINE(ST_GEOGFROMTEXT('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 10000, NULL) as bezierspline3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].BEZIERSPLINE1).toEqual(null);
    expect(rows[0].BEZIERSPLINE2).toEqual(null);
    expect(rows[0].BEZIERSPLINE3).toEqual(null);
});

test('ST_BEZIERSPLINE default values should work', async () => {
    const query = `
        SELECT ST_BEZIERSPLINE(ST_GEOGFROMTEXT('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 10000, 0.85) as defaultValue,
               ST_BEZIERSPLINE(ST_GEOGFROMTEXT('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)')) as nullParam1,
               ST_BEZIERSPLINE(ST_GEOGFROMTEXT('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 10000) as nullParam2
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].NULLPARAM1).toEqual(rows[0].DEFAULTVALUE);
    expect(rows[0].NULLPARAM2).toEqual(rows[0].DEFAULTVALUE);
});