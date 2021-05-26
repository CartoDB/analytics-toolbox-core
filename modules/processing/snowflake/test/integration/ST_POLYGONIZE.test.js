const { runQuery } = require('../../../../../common/snowflake/test-utils');
const fixturesIn = require('./polygonize_fixtures/in');
const fixturesOut = require('./polygonize_fixtures/out');

test('ST_POLYGONIZE should work', async () => {
    const query = `WITH polygons AS (
        SELECT @@SF_PREFIX@@processing.ST_POLYGONIZE(${fixturesIn.linesArray})
        AS polygonsArray  
    )
    SELECT ST_ASWKT(TO_GEOGRAPHY(unnested.VALUE)) AS geom
    FROM polygons, LATERAL FLATTEN(input => polygonsArray) AS unnested`;
    
    const rows = await runQuery(query);
    expect(rows.length).toEqual(fixturesOut.expectedPolygons.length);
    expect(rows.map(item => item.GEOM)).toEqual(fixturesOut.expectedPolygons);
});

test('ST_POLYGONIZE should fail if a degenerated line path is received', async () => {
    const query =  `SELECT @@SF_PREFIX@@processing.ST_POLYGONIZE(${fixturesIn.degeneratedLine})`;
    await expect(runQuery(query)).rejects.toThrow(
        'The first and last vertex of a loop are not equal'
    );
});

test('ST_POLYGONIZE should fail if a path with less than 4 nodes is received', async () => {
    const query =  `SELECT @@SF_PREFIX@@processing.ST_POLYGONIZE(${fixturesIn.invalidPath})`;
    await expect(runQuery(query)).rejects.toThrow(
        'Loop array should have at least 4 elements'
    );
});