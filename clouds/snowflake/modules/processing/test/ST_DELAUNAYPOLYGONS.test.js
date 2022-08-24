const { runQuery } = require('../../../common/test-utils');
const fixturesIn = require('./fixtures/st_delaunay_in');
const fixturesOut = require('./fixtures/st_delaunay_out');

test('ST_DELAUNAYPOLYGONS should work', async () => {
    const query = `WITH delaunay AS (
        SELECT ST_DELAUNAYPOLYGONS(${fixturesIn.input1})
        AS delaunayArray
      )
      SELECT ST_ASWKT(TO_GEOGRAPHY(unnested.VALUE)) AS geom
      FROM delaunay, LATERAL FLATTEN(input => delaunayArray) AS unnested`
    
    const rows = await runQuery(query);
    expect(rows.length).toEqual(fixturesOut.expectedPolygons1.length);
    expect(rows.map(item => item.GEOM)).toEqual(fixturesOut.expectedPolygons1);
});

test('ST_DELAUNAYPOLYGONS should return an empty array if passed null geometry', async () => {
    const query = 'SELECT ST_DELAUNAYPOLYGONS(ARRAY_CONSTRUCT()) as delaunay';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].DELAUNAY).toEqual([]);
});