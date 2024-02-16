const { runQuery } = require('../../../common/test-utils');
const fixturesIn = require('./fixtures/st_voronoi_in');
const fixturesOut = require('./fixtures/st_voronoi_out');

let geojsonArray = 'ARRAY_CONSTRUCT(';
fixturesIn.points.features.forEach((item) => {
    geojsonArray += 'ST_ASGEOJSON(TO_GEOGRAPHY(\'' + JSON.stringify(item.geometry) +'\'))::STRING,';
});

geojsonArray = geojsonArray.slice(0, -1) + ')';

test('ST_VORONOILINES should work', async () => {
    const query = `WITH voronoi AS (
            SELECT ST_VORONOILINES(${geojsonArray}, 
                ARRAY_CONSTRUCT(-76.0, 35.0, -70.0, 45.0)) AS geomArray
        ) 
        SELECT ST_ASWKT(TO_GEOGRAPHY(unnestedFeatures.value)) as geom
        FROM voronoi, LATERAL FLATTEN(input => voronoi.geomArray) as unnestedFeatures`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(fixturesOut.expectedLines1.length);
    expect(rows.map(item => item.GEOM)).toEqual(expect.arrayContaining(fixturesOut.expectedLines1));
});


test('ST_VORONOILINES should work with default bbox', async () => {
    const query = `WITH voronoi AS (
            SELECT ST_VORONOILINES(${geojsonArray}) AS geomArray
        ) 
        SELECT ST_ASWKT(TO_GEOGRAPHY(unnestedFeatures.value)) as geom
        FROM voronoi, LATERAL FLATTEN(input => voronoi.geomArray) as unnestedFeatures`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(fixturesOut.expectedLines2.length);
    expect(rows.map(item => item.GEOM)).toEqual(fixturesOut.expectedLines2);
});

test('ST_VORONOILINES should return an empty array if passed empty geometry', async () => {
    const query = 'SELECT ST_VORONOILINES(ARRAY_CONSTRUCT()) AS geomArray';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].GEOMARRAY).toEqual([]);
});

test('ST_VORONOILINES should fail if passed invalid bbox', async () => {
    const query = `SELECT ST_VORONOILINES(${geojsonArray}, 
        ARRAY_CONSTRUCT(1.0, 0.5, 2.5)) AS geomArray`;
    await expect(runQuery(query)).rejects.toThrow(
        'It should contain the BBOX extends, i.e., [xmin, ymin, xmax, ymax]'
    );
});

test('ST_VORONOILINES should return NULL if any NULL mandatory argument', async () => {
    const query = `
        SELECT ST_VORONOILINES(NULL) as voronoi1,
               ST_VORONOILINES(ARRAY_CONSTRUCT(), NULL) as voronoi2
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].VORONOI1.length).toEqual(0);
    expect(rows[0].VORONOI2.length).toEqual(0);
});