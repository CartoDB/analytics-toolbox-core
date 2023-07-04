const { runQuery } = require('../../../common/test-utils');

test('H3_POLYFILL_MODE center wrong input round 1', async () => {
    const query = `
        WITH inputs AS
        (
            -- NULL and empty
            SELECT 0 AS id, NULL as geom, 2 as resolution UNION ALL
            SELECT 1 AS id, ST_GEOGFROMTEXT('POLYGON EMPTY') as geom, 2 as resolution UNION ALL

            -- Invalid resolution
            SELECT 2 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution UNION ALL
            --SELECT 3 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 16 as resolution UNION ALL
            SELECT 4 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, NULL as resolution
        )
        SELECT
        \`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'center') AS results
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(4);
    expect(rows.map((r) => r.results)).toEqual([
        [],
        [],
        [],
        [],
    ]);
});

test('H3_POLYFILL_MODE center wrong input round 2', async () => {
    const query = `
        WITH inputs AS
        (
        -- Invalid resolution
        -- uncommenting the below query result in unuexpected
        -- _INIT executtion that result in timout in the subsequent
        -- query with wrong resulution 16
        -- SELECT 10 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution UNION ALL
        SELECT 11 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 16 as resolution
        )
        SELECT
        \`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'center') AS results
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows.map((r) => r.results)).toEqual([
        []
    ]);
});

test('H3_POLYFILL_MODE intersects wrong input round 1', async () => {
    const query = `
        WITH inputs AS
        (
            -- NULL and empty
            SELECT 0 AS id, NULL as geom, 2 as resolution UNION ALL
            SELECT 1 AS id, ST_GEOGFROMTEXT('POLYGON EMPTY') as geom, 2 as resolution UNION ALL

            -- Invalid resolution
            SELECT 2 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution UNION ALL
            --SELECT 3 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 16 as resolution UNION ALL
            SELECT 4 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, NULL as resolution
        )
        SELECT
        \`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'intersects') AS results
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(4);
    expect(rows.map((r) => r.results)).toEqual([
        [],
        [],
        [],
        [],
    ]);
});

test('H3_POLYFILL_MODE intersects wrong input round 2', async () => {
    const query = `
        WITH inputs AS
        (
        -- Invalid resolution
        -- uncommenting the below query result in unuexpected
        -- _INIT executtion that result in timout in the subsequent
        -- query with wrong resulution 16
        -- SELECT 10 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution UNION ALL
        SELECT 11 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 16 as resolution
        )
        SELECT
        \`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'intersects') AS results
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows.map((r) => r.results)).toEqual([
        []
    ]);
});

test('H3_POLYFILL_MODE contains wrong input round 1', async () => {
    const query = `
        WITH inputs AS
        (
            -- NULL and empty
            SELECT 0 AS id, NULL as geom, 2 as resolution UNION ALL
            SELECT 1 AS id, ST_GEOGFROMTEXT('POLYGON EMPTY') as geom, 2 as resolution UNION ALL

            -- Invalid resolution
            SELECT 2 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution UNION ALL
            --SELECT 3 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 16 as resolution UNION ALL
            SELECT 4 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, NULL as resolution
        )
        SELECT
        \`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'contains') AS results
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(4);
    expect(rows.map((r) => r.results)).toEqual([
        [],
        [],
        [],
        [],
    ]);
});

test('H3_POLYFILL_MODE contains wrong input round 2', async () => {
    const query = `
        WITH inputs AS
        (
        -- Invalid resolution
        -- uncommenting the below query result in unuexpected
        -- _INIT executtion that result in timout in the subsequent
        -- query with wrong resulution 16
        -- SELECT 10 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution UNION ALL
        SELECT 11 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 16 as resolution
        )
        SELECT
        \`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'contains') AS results
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows.map((r) => r.results)).toEqual([
        []
    ]);
});

test('H3_POLYFILL_MODE center polygons', async () => {
    const query = `
        WITH inputs AS
        (
            SELECT 1 AS id, ST_GEOGFROMTEXT('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))') as geom, 9 as resolution UNION ALL
            SELECT 2 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 2 as resolution UNION ALL
            SELECT 3 AS id, ST_GEOGFROMTEXT('POLYGON((20 20, 20 30, 30 30, 30 20, 20 20))') as geom, 2 as resolution UNION ALL
            -- 4 is a multipolygon containing geom ids 2, 3
            SELECT 4 AS id, ST_GEOGFROMTEXT('MULTIPOLYGON(((0 0, 0 10, 10 10, 10 0, 0 0)), ((20 20, 20 30, 30 30, 30 20, 20 20)))') as geom, 2 as resolution UNION ALL
            SELECT 5 AS id, ST_GEOGFROMTEXT('GEOMETRYCOLLECTION(POLYGON((20 20, 20 30, 30 30, 30 20, 20 20)), POINT(0 10), LINESTRING(0 0, 1 1),MULTIPOLYGON(((-50 -50, -50 -40, -40 -40, -40 -50, -50 -50)), ((50 50, 50 40, 40 40, 40 50, 50 50))))') as geom, 2 as resolution UNION ALL

            SELECT 6 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 .0001, .0001 .0001, .0001 0, 0 0))') as geom, 15 as resolution UNION ALL
            SELECT 7 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 50, 50 50, 50 0, 0 0))') as geom, 0 as resolution
        )
        SELECT
        ARRAY_LENGTH(\`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'center')) AS id_count
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(7);
    expect(rows.map((r) => r.id_count)).toEqual([
        1253,
        18,
        12,
        30,
        34,
        182,
        6
    ]);
});

test('H3_POLYFILL_MODE intersects polygons', async () => {
    const query = `
        WITH inputs AS
        (
            SELECT 1 AS id, ST_GEOGFROMTEXT('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))') as geom, 9 as resolution UNION ALL
            SELECT 2 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 2 as resolution UNION ALL
            SELECT 3 AS id, ST_GEOGFROMTEXT('POLYGON((20 20, 20 30, 30 30, 30 20, 20 20))') as geom, 2 as resolution UNION ALL
            -- 4 is a multipolygon containing geom ids 2, 3
            SELECT 4 AS id, ST_GEOGFROMTEXT('MULTIPOLYGON(((0 0, 0 10, 10 10, 10 0, 0 0)), ((20 20, 20 30, 30 30, 30 20, 20 20)))') as geom, 2 as resolution UNION ALL
            SELECT 5 AS id, ST_GEOGFROMTEXT('GEOMETRYCOLLECTION(POLYGON((20 20, 20 30, 30 30, 30 20, 20 20)), POINT(0 10), LINESTRING(0 0, 1 1),MULTIPOLYGON(((-50 -50, -50 -40, -40 -40, -40 -50, -50 -50)), ((50 50, 50 40, 40 40, 40 50, 50 50))))') as geom, 2 as resolution UNION ALL

            SELECT 6 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 .0001, .0001 .0001, .0001 0, 0 0))') as geom, 15 as resolution UNION ALL
            SELECT 7 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 50, 50 50, 50 0, 0 0))') as geom, 0 as resolution
        )
        SELECT
        ARRAY_LENGTH(\`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'intersects')) AS id_count
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(7);
    expect(rows.map((r) => r.id_count)).toEqual([
        1332,
        27,
        18,
        45,
        59,
        219,
        13,
    ]);
});

test('H3_POLYFILL_MODE contains polygons', async () => {
    const query = `
        WITH inputs AS
        (
            SELECT 1 AS id, ST_GEOGFROMTEXT('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))') as geom, 9 as resolution UNION ALL
            SELECT 2 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 2 as resolution UNION ALL
            SELECT 3 AS id, ST_GEOGFROMTEXT('POLYGON((20 20, 20 30, 30 30, 30 20, 20 20))') as geom, 2 as resolution UNION ALL
            -- 4 is a multipolygon containing geom ids 2, 3
            SELECT 4 AS id, ST_GEOGFROMTEXT('MULTIPOLYGON(((0 0, 0 10, 10 10, 10 0, 0 0)), ((20 20, 20 30, 30 30, 30 20, 20 20)))') as geom, 2 as resolution UNION ALL
            SELECT 5 AS id, ST_GEOGFROMTEXT('GEOMETRYCOLLECTION(POLYGON((20 20, 20 30, 30 30, 30 20, 20 20)), POINT(0 10), LINESTRING(0 0, 1 1),MULTIPOLYGON(((-50 -50, -50 -40, -40 -40, -40 -50, -50 -50)), ((50 50, 50 40, 40 40, 40 50, 50 50))))') as geom, 2 as resolution UNION ALL

            SELECT 6 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 .0001, .0001 .0001, .0001 0, 0 0))') as geom, 15 as resolution UNION ALL
            SELECT 7 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 50, 50 50, 50 0, 0 0))') as geom, 0 as resolution
        )
        SELECT
        ARRAY_LENGTH(\`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'contains')) AS id_count
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(7);
    expect(rows.map((r) => r.id_count)).toEqual([
        1175,
        8,
        5,
        13,
        13,
        157,
        1,
    ]);
});

test('H3_POLYFILL_MODE center other geometries', async () => {
    const query = `
        WITH inputs AS
        (
            -- Other supported types
            SELECT 0 AS id, ST_GEOGFROMTEXT('POINT(0 0)') as geom, 15 as resolution UNION ALL
            SELECT 1 AS id, ST_GEOGFROMTEXT('MULTIPOINT(0 0, 1 1)') as geom, 15 as resolution UNION ALL
            SELECT 2 AS id, ST_GEOGFROMTEXT('LINESTRING(0 0, 1 1)') as geom, 3 as resolution UNION ALL
            SELECT 3 AS id, ST_GEOGFROMTEXT('MULTILINESTRING((0 0, 1 1), (2 2, 3 3))') as geom, 3 as resolution UNION ALL
            -- a geometry collection containing only not supported types
            SELECT 4 AS id, ST_GEOGFROMTEXT('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))') as geom, 1 as resolution UNION ALL
            -- Polygon larger than 180 degrees
            SELECT 5 AS id, ST_GEOGFROMGEOJSON('{"type":"Polygon","coordinates":[[[-161.44993041898587,-3.77971025880735],[129.99811811657568,-3.77971025880735],[129.99811811657568,63.46915831771922],[-161.44993041898587,63.46915831771922],[-161.44993041898587,-3.77971025880735]]]}') as geom, 3 as resolution
        )
        SELECT
        ARRAY_LENGTH(\`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'center')) AS id_count
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(6);
    expect(rows.map((r) => r.id_count)).toEqual([
        null,
        null,
        null,
        null,
        null,
        16110,
    ]);
});

test('H3_POLYFILL_MODE intersects other geometries', async () => {
    const query = `
        WITH inputs AS
        (
            -- Other supported types
            SELECT 0 AS id, ST_GEOGFROMTEXT('POINT(0 0)') as geom, 15 as resolution UNION ALL
            SELECT 1 AS id, ST_GEOGFROMTEXT('MULTIPOINT(0 0, 1 1)') as geom, 15 as resolution UNION ALL
            SELECT 2 AS id, ST_GEOGFROMTEXT('LINESTRING(0 0, 1 1)') as geom, 3 as resolution UNION ALL
            SELECT 3 AS id, ST_GEOGFROMTEXT('MULTILINESTRING((0 0, 1 1), (2 2, 3 3))') as geom, 3 as resolution UNION ALL
            -- a geometry collection containing only not supported types
            SELECT 4 AS id, ST_GEOGFROMTEXT('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))') as geom, 1 as resolution UNION ALL
            -- Polygon larger than 180 degrees
            SELECT 5 AS id, ST_GEOGFROMGEOJSON('{"type":"Polygon","coordinates":[[[-161.44993041898587,-3.77971025880735],[129.99811811657568,-3.77971025880735],[129.99811811657568,63.46915831771922],[-161.44993041898587,63.46915831771922],[-161.44993041898587,-3.77971025880735]]]}') as geom, 3 as resolution
        )
        SELECT
        ARRAY_LENGTH(\`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'intersects')) AS id_count
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(6);
    expect(rows.map((r) => r.id_count)).toEqual([
        1,
        2,
        2,
        4,
        1,
        16436,
    ]);
});

test('H3_POLYFILL_MODE contains other geometries', async () => {
    const query = `
        WITH inputs AS
        (
            -- Other supported types
            SELECT 0 AS id, ST_GEOGFROMTEXT('POINT(0 0)') as geom, 15 as resolution UNION ALL
            SELECT 1 AS id, ST_GEOGFROMTEXT('MULTIPOINT(0 0, 1 1)') as geom, 15 as resolution UNION ALL
            SELECT 2 AS id, ST_GEOGFROMTEXT('LINESTRING(0 0, 1 1)') as geom, 3 as resolution UNION ALL
            SELECT 3 AS id, ST_GEOGFROMTEXT('MULTILINESTRING((0 0, 1 1), (2 2, 3 3))') as geom, 3 as resolution UNION ALL
            -- a geometry collection containing only not supported types
            SELECT 4 AS id, ST_GEOGFROMTEXT('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))') as geom, 1 as resolution UNION ALL
            -- Polygon larger than 180 degrees
            SELECT 5 AS id, ST_GEOGFROMGEOJSON('{"type":"Polygon","coordinates":[[[-161.44993041898587,-3.77971025880735],[129.99811811657568,-3.77971025880735],[129.99811811657568,63.46915831771922],[-161.44993041898587,63.46915831771922],[-161.44993041898587,-3.77971025880735]]]}') as geom, 3 as resolution
        )
        SELECT
        ARRAY_LENGTH(\`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(geom, resolution, 'contains')) AS id_count
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(6);
    expect(rows.map((r) => r.id_count)).toEqual([
        null,
        null,
        null,
        null,
        null,
        15785,
    ]);
});
