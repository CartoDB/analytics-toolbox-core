const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('H3_POLYFILL returns the proper INT64s', async () => {
    const query = `
        WITH inputs AS
        (
            SELECT 1 AS id, TO_GEOGRAPHY('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))') as geom, 9 as resolution UNION ALL
            SELECT 2 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 2 as resolution UNION ALL
            SELECT 3 AS id, TO_GEOGRAPHY('POLYGON((20 20, 20 30, 30 30, 30 20, 20 20))') as geom, 2 as resolution UNION ALL
            -- 4 is a multipolygon containing geom ids 2, 3
            SELECT 4 AS id, TO_GEOGRAPHY('MULTIPOLYGON(((0 0, 0 10, 10 10, 10 0, 0 0)), ((20 20, 20 30, 30 30, 30 20, 20 20)))') as geom, 2 as resolution UNION ALL
            SELECT 5 AS id, TO_GEOGRAPHY('GEOMETRYCOLLECTION(POLYGON((20 20, 20 30, 30 30, 30 20, 20 20)), POINT(0 10), LINESTRING(0 0, 1 1),MULTIPOLYGON(((-50 -50, -50 -40, -40 -40, -40 -50, -50 -50)), ((50 50, 50 40, 40 40, 40 50, 50 50))))') as geom, 2 as resolution UNION ALL

            -- NULL and empty
            SELECT 6 AS id, TRY_TO_GEOGRAPHY(NULL) as geom, 2 as resolution UNION ALL
            SELECT 7 AS id, TO_GEOGRAPHY('POLYGON EMPTY') as geom, 2 as resolution UNION ALL

            -- Invalid resolution
            SELECT 8 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution UNION ALL
            SELECT 9 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 20 as resolution UNION ALL
            SELECT 10 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, NULL as resolution UNION ALL

            -- Other types
            SELECT 11 AS id, TO_GEOGRAPHY('POINT(0 0)') as geom, 15 as resolution UNION ALL
            SELECT 12 AS id, TO_GEOGRAPHY('MULTIPOINT(0 0, 1 1)') as geom, 5 as resolution UNION ALL
            SELECT 13 AS id, TO_GEOGRAPHY('LINESTRING(0 0, 1 1)') as geom, 5 as resolution UNION ALL
            SELECT 14 AS id, TO_GEOGRAPHY('MULTILINESTRING((0 0, 1 1), (2 2, 3 3))') as geom, 5 as resolution

        )
        SELECT
            ARRAY_SIZE(H3_POLYFILL(geom, resolution)) AS id_count
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(14);
    expect(rows.map((r) => r.ID_COUNT)).toEqual([
        1253,
        18,
        12,
        30,
        34,
        0,
        0,
        0,
        0,
        0,
        0,
        66,
        66,
        579
    ]);
});

test('H3_POLYFILL returns the expected values', async () => {
    /* Any cell should cover only 1 h3 cell at its resolution (itself) */
    /* This query has been splitted in Snowflake to avoid JS memory limits reached*/
    let query = `
        WITH points AS
        (
            SELECT ST_POINT(0, 0) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    let rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.4089866999972145, 37.813318999983238) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.0553238, 37.3615593) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});