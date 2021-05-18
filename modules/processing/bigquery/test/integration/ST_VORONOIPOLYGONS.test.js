const { runQuery } = require('../../../../../common/bigquery/test-utils');
const fixturesIn = require('./voronoi_fixtures/in');
const fixturesOut = require('./voronoi_fixtures/out');

const pointsArray = [];
fixturesIn.points.features.forEach((item) => {
    pointsArray.push(`ST_GEOGPOINT(${item.geometry.coordinates[0]},${item.geometry.coordinates[1]})`);
});

test('ST_VORONOIPOLYGONS should work', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@processing.ST_VORONOIPOLYGONS\`([${pointsArray}], [-76.0, 35.0, -70.0, 45.0]) as voronoi`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].voronoi.map(item => item.value)).toEqual(fixturesOut.expectedPoly1);
});

test('ST_VORONOIPOLYGONS should work with null bbox', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@processing.ST_VORONOIPOLYGONS\`([${pointsArray}], null) as voronoi`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].voronoi.map(item => item.value)).toEqual(fixturesOut.expectedPoly2);
});

test('ST_VORONOIPOLYGONS should return an empty array if passed null geometry', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@processing.ST_VORONOIPOLYGONS`(null, null) as voronoi';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].voronoi).toEqual([]);
});

test('ST_VORONOILINES should fail if passed invalid bbox', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@processing.ST_VORONOIPOLYGONS\`([${pointsArray}], [1.0, 0.5, 2.5])`;
    await expect(runQuery(query)).rejects.toThrow(
        'Error: Incorrect bounding box passed to UDF. It should contain the bbox extends, i.e., [xmin, ymin, xmax, ymax] at UDF$1(ARRAY<STRING>, ARRAY<FLOAT64>, STRING) line 7, columns 8-9'
    );
});