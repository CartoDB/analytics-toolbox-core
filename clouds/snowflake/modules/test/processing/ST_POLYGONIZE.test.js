const { runQuery } = require('../../../common/test-utils');
const fixturesIn = require('./fixtures/st_polygonize_in');
const fixturesOut = require('./fixtures/st_polygonize_out');

test('ST_POLYGONIZE should work', async () => {
    const query = `WITH polygons AS (
        SELECT ST_POLYGONIZE(${fixturesIn.linesArray})
        AS polygonsArray  
    )
    SELECT ST_ASWKT(TO_GEOGRAPHY(unnested.VALUE)) AS geom
    FROM polygons, LATERAL FLATTEN(input => polygonsArray) AS unnested`;
    
    const rows = await runQuery(query);
    expect(rows.length).toEqual(fixturesOut.expectedPolygons.length);
    expect(rows.map(item => item.GEOM)).toEqual(fixturesOut.expectedPolygons);
});

test('ST_POLYGONIZE should fail if a degenerated line path is received', async () => {
    const query =  `SELECT ST_POLYGONIZE(${fixturesIn.degeneratedLine})`;
    await expect(runQuery(query)).rejects.toThrow(
        'The first and last vertex of a loop are not equal'
    );
});

test('ST_POLYGONIZE should fail if a path with less than 4 nodes is received', async () => {
    const query =  `SELECT ST_POLYGONIZE(${fixturesIn.invalidPath})`;
    await expect(runQuery(query)).rejects.toThrow(
        'Loop array should have at least 4 elements'
    );
});