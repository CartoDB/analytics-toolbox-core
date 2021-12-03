const { runQuery } = require('../../../../../common/snowflake/test-utils');
const fixturesIn = require('./voronoi_fixtures/in');
const fixturesOut = require('./voronoi_fixtures/out');

let geojsonArray = 'ARRAY_CONSTRUCT(';
fixturesIn.points.features.forEach((item) => {
    geojsonArray += 'ST_ASGEOJSON(TO_GEOGRAPHY(\'' + JSON.stringify(item.geometry) +'\'))::STRING,';
});

geojsonArray = geojsonArray.slice(0, -1) + ')';

test('ST_VORONOIPOLYGONS should work', async () => {
    const query = `WITH voronoi AS (
            SELECT ST_VORONOIPOLYGONS(${geojsonArray}, 
                ARRAY_CONSTRUCT(-76.0, 35.0, -70.0, 45.0)) AS geomArray
        ) 
        SELECT ST_ASWKT(TO_GEOGRAPHY(unnestedFeatures.value)) as geom
        FROM voronoi, LATERAL FLATTEN(input => voronoi.geomArray) as unnestedFeatures`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(fixturesOut.expectedPoly1.length);
    expect(rows.map(item => item.GEOM)).toEqual(fixturesOut.expectedPoly1);
});


test('ST_VORONOIPOLYGONS should work with default bbox', async () => {
    const query = `WITH voronoi AS (
            SELECT ST_VORONOIPOLYGONS(${geojsonArray}) AS geomArray
        ) 
        SELECT ST_ASWKT(TO_GEOGRAPHY(unnestedFeatures.value)) as geom
        FROM voronoi, LATERAL FLATTEN(input => voronoi.geomArray) as unnestedFeatures`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(fixturesOut.expectedPoly2.length);
    expect(rows.map(item => item.GEOM)).toEqual(fixturesOut.expectedPoly2);
});

test('ST_VORONOIPOLYGONS should return an empty array if passed empty geometry', async () => {
    const query = 'SELECT ST_VORONOIPOLYGONS(ARRAY_CONSTRUCT()) AS geomArray';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].GEOMARRAY).toEqual([]);
});

test('ST_VORONOIPOLYGONS should fail if passed invalid bbox', async () => {
    const query = `SELECT ST_VORONOIPOLYGONS(${geojsonArray}, 
        ARRAY_CONSTRUCT(1.0, 0.5, 2.5)) AS geomArray`;
    await expect(runQuery(query)).rejects.toThrow(
        'It should contain the BBOX extends, i.e., [xmin, ymin, xmax, ymax]'
    );
});

test('ST_VORONOIPOLYGONS should return NULL if any NULL mandatory argument', async () => {
    const query = `
        SELECT ST_VORONOIPOLYGONS(NULL) as voronoi1,
               ST_VORONOIPOLYGONS(ARRAY_CONSTRUCT(), NULL) as voronoi2
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].VORONOI1.length).toEqual(0);
    expect(rows[0].VORONOI2.length).toEqual(0);
});