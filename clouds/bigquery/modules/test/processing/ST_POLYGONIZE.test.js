const { runQuery } = require('../../../common/test-utils');
const fixturesIn = require('./fixtures/st_polygonize_in');
const fixturesOut = require('./fixtures/st_polygonize_out');

test('ST_POLYGONIZE should work', async () => {
    const query = `SELECT \`@@BQ_DATASET@@.ST_POLYGONIZE\`([${fixturesIn.linesArray}]) as polygons`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].polygons.map(item => item.value)).toEqual(fixturesOut.expectedPolygons);
});

test('ST_POLYGONIZE should fail if a degenerated line path is received', async () => {
    const query =  `SELECT \`@@BQ_DATASET@@.ST_POLYGONIZE\`(${fixturesIn.degeneratedLine})`;
    await expect(runQuery(query)).rejects.toThrow(
        'ST_MakePolygon failed: Invalid polygon loop: Edge 2 has duplicate vertex with edge 4'
    );
});

test('ST_POLYGONIZE should fail if a path with less than 3 nodes is received', async () => {
    const query =  `SELECT \`@@BQ_DATASET@@.ST_POLYGONIZE\`(${fixturesIn.invalidPath})`;
    await expect(runQuery(query)).rejects.toThrow(
        'ST_MakePolygon failed: A polygon loop must have at least 3 distinct vertices.'
    );
});