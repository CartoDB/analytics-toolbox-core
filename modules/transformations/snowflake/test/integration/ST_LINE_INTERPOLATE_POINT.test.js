const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('ST_LINE_INTERPOLATE_POINT should work', async () => {
    const query = `SELECT ST_LINE_INTERPOLATE_POINT(TO_GEOGRAPHY('LINESTRING (0 0, 10 0)'), 250,'kilometers') as interpolation1,
    ST_LINE_INTERPOLATE_POINT(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 10, 'kilometers') as interpolation2,
    ST_LINE_INTERPOLATE_POINT(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 10, 'miles') as interpolation3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].INTERPOLATION1)).toEqual('{"coordinates":[2.2483009093113493,1.419623930906554e-15],"type":"Point"}');
    expect(JSON.stringify(rows[0].INTERPOLATION2)).toEqual('{"coordinates":[-76.17510492482248,18.4695609401574],"type":"Point"}');
    expect(JSON.stringify(rows[0].INTERPOLATION3)).toEqual('{"coordinates":[-76.22618621718455,18.495171853822487],"type":"Point"}');
});

test('ST_LINE_INTERPOLATE_POINT should return NULL if any NULL mandatory argument', async () => {
    const query = `SELECT ST_LINE_INTERPOLATE_POINT(NULL, 250,'miles') as interpolation1,
    ST_LINE_INTERPOLATE_POINT(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), NULL, 'miles') as interpolation2,
    ST_LINE_INTERPOLATE_POINT(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 250, NULL) as interpolation3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].INTERPOLATION1).toEqual(null);
    expect(rows[0].INTERPOLATION2).toEqual(null);
    expect(rows[0].INTERPOLATION3).toEqual(null);
});

test('ST_LINE_INTERPOLATE_POINT default values should work', async () => {
    const query = `SELECT ST_LINE_INTERPOLATE_POINT(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 250, 'kilometers') as defaultValue,
    ST_LINE_INTERPOLATE_POINT(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 250) as nullParam1`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].NULLPARAM1).toEqual(rows[0].DEFAULTVALUE);
});