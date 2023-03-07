const { runQuery } = require('../../../common/test-utils');
const fixturesIn = require('./fixtures/st_delaunay_in');
const fixturesOut = require('./fixtures/st_delaunay_out');

test('ST_DELAUNAYPOLYGONS should work', async () => {
    const query = `SELECT \`@@BQ_DATASET@@.ST_DELAUNAYPOLYGONS\`(${fixturesIn.input2}) as delaunay`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].delaunay.map(item => item.value)).toEqual(expect.arrayContaining(fixturesOut.expectedTriangles2));
});

test('ST_DELAUNAYPOLYGONS should return an empty array if passed null geometry', async () => {
    const query = 'SELECT `@@BQ_DATASET@@.ST_DELAUNAYPOLYGONS`(null) as delaunay';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].delaunay).toEqual([]);
});