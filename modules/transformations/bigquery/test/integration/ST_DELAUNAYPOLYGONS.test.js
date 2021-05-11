const { runQuery } = require('../../../../../common/bigquery/test-utils');
const fixturesIn = require('./delaunay_fixtures/in');
const fixturesOut = require('./delaunay_fixtures/out');

test('ST_DELAUNAYPOLYGONS should work', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@processing.ST_DELAUNAYPOLYGONS\`(${fixturesIn.input2}) as delaunay`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].delaunay.map(item => item.value)).toEqual(fixturesOut.expectedTriangles2);
});

test('ST_DELAUNAYPOLYGONS should return an empty array if passed null geometry', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@processing.ST_DELAUNAYPOLYGONS`(null) as delaunay';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].delaunay).toEqual([]);
});
