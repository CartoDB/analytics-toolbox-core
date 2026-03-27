const { runQuery, isGeometryCloseTo } = require('../../../common/test-utils');

test('ST_GREATCIRCLE should work', async () => {
    // ST_ASGEOJSON returns GeoJSON objects directly (no PARSE_JSON needed)
    const query = `SELECT
        ST_ASGEOJSON(ST_GREATCIRCLE(ST_POINT(0, 0), ST_POINT(0, 10), 11)) as greatcircle1,
        ST_ASGEOJSON(ST_GREATCIRCLE(ST_POINT(-1.70325, 1.4167), ST_POINT(1.70325, -1.4167), 5)) as greatcircle2,
        ST_ASGEOJSON(ST_GREATCIRCLE(ST_POINT(5, 5), ST_POINT(-5, -5), 9)) as greatcircle3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);

    // Test GREATCIRCLE1 - simple north-south line
    expect(isGeometryCloseTo(rows[0].GREATCIRCLE1, {
        type: 'LineString',
        coordinates: [
            [0, 0], [0, 1], [0, 2], [0, 3], [0, 4], [0, 5],
            [0, 6], [0, 7], [0, 8], [0, 9], [0, 10]
        ]
    })).toBe(true);

    // Test GREATCIRCLE2 - diagonal line
    expect(isGeometryCloseTo(rows[0].GREATCIRCLE2, {
        type: 'LineString',
        coordinates: [
            [-1.70325, 1.4167], [-0.851495, 0.708428], [0, 0],
            [0.851495, -0.708428], [1.70325, -1.4167]
        ]
    })).toBe(true);

    // Test GREATCIRCLE3 - longer diagonal line
    expect(isGeometryCloseTo(rows[0].GREATCIRCLE3, {
        type: 'LineString',
        coordinates: [
            [5, 5], [3.745825, 3.752083], [2.495231, 2.502379],
            [1.24702, 1.251486], [0, 0], [-1.24702, -1.251486],
            [-2.495231, -2.502379], [-3.745825, -3.752083], [-5, -5]
        ]
    })).toBe(true);
});

test('ST_GREATCIRCLE should return NULL if any NULL mandatory argument', async () => {
    const query = `SELECT ST_GREATCIRCLE(NULL, ST_POINT(-73.9385,40.6643), 20) as greatcircle1,
    ST_GREATCIRCLE(ST_POINT(-3.70325,40.4167), NULL, 20) as greatcircle2,
    ST_GREATCIRCLE(ST_POINT(-3.70325,40.4167), ST_POINT(-73.9385,40.6643), NULL) as greatcircle3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].GREATCIRCLE1).toEqual(null);
    expect(rows[0].GREATCIRCLE2).toEqual(null);
    expect(rows[0].GREATCIRCLE3).toEqual(null);
});

test('ST_GREATCIRCLE should return NULL if start and end are equal', async () => {
    const query = 'SELECT ST_GREATCIRCLE(ST_POINT(0, 0), ST_POINT(0, 0), 11) as greatcircle';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].GREATCIRCLE).toEqual(null);
});

test('ST_GREATCIRCLE default values should work', async () => {
    const query = `SELECT ST_GREATCIRCLE(ST_POINT(-3.70325,40.4167), ST_POINT(-73.9385,40.6643), 100) as defaultValue,
    ST_GREATCIRCLE(ST_POINT(-3.70325,40.4167), ST_POINT(-73.9385,40.6643)) as nullParam1`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].NULLPARAM1).toEqual(rows[0].DEFAULTVALUE);
});