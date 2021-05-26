const { runQuery } = require('../../../../../common/snowflake/test-utils');
const fixturesIn = require('./delaunay_fixtures/in');
const fixturesOut = require('./delaunay_fixtures/out');

test('ST_DELAUNAYPOLYGONS should work', async () => {
    const query = `WITH delaunay AS (
        SELECT @@SF_PREFIX@@processing.ST_DELAUNAYPOLYGONS(${fixturesIn.input1})
        AS delaunayArray
      )
      SELECT ST_ASWKT(TO_GEOGRAPHY(unnested.VALUE)) AS geom
      FROM delaunay, LATERAL FLATTEN(input => delaunayArray) AS unnested`
    
    const rows = await runQuery(query);
    expect(rows.length).toEqual(fixturesOut.expectedTriangles1.length);
    expect(rows.map(item => item.GEOM)).toEqual(fixturesOut.expectedTriangles2);
});

test('ST_DELAUNAYPOLYGONS should return an empty array if passed null geometry', async () => {
    const query = 'SELECT @@SF_PREFIX@@processing.ST_DELAUNAYPOLYGONS(ARRAY_CONSTRUCT()) as delaunay';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].DELAUNAY).toEqual([]);
});