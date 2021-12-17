const { runQuery } = require('../../../../../common/bigquery/test-utils');
const fixturesIn = require('./delaunay_fixtures/in');
const fixturesOut = require('./delaunay_fixtures/out');

test('ST_DELAUNAYLINES should work', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@carto.ST_DELAUNAYLINES\`(${fixturesIn.input1}) as delaunay`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].delaunay.map(item => item.value)).toEqual(fixturesOut.expectedTriangles1);
});

test('ST_DELAUNAYLINES should return an empty array if passed null geometry', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.ST_DELAUNAYLINES`(null) as delaunay';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].delaunay).toEqual([]);
});