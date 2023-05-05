const { runQuery } = require('../../../common/test-utils');

test('ST_CONVEXHULL should work', async () => {
    const query = 'SELECT ST_CONVEXHULL(TO_GEOGRAPHY(\'LINESTRING (-3.5938 41.0403, -4.4006 40.3266, -3.14655 40.1193, -3.7205 40.4743)\')) AS CONVEXHULL';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].CONVEXHULL)).toEqual('{"coordinates":[[[-3.14655,40.1193],[-4.4006,40.3266],[-3.5938,41.0403],[-3.14655,40.1193]]],"type":"Polygon"}');
});

test('ST_CONVEXHULL should return NULL if any NULL argument', async () => {
    const query = 'SELECT ST_CONVEXHULL(NULL) AS CONVEXHULL';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].CONVEXHULL).toEqual(null);
});