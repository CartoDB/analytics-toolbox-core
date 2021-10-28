const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('H3_FROMGEOGPOINT returns the proper INT64', async () => {
    const query = `
        WITH inputs AS
        (
            SELECT 1 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, 5 as resolution UNION ALL
            SELECT 2 AS id, ST_POINT(-164.991559, 30.943387) as geom, 5 as resolution UNION ALL
            SELECT 3 AS id, ST_POINT(71.52790329909925, 46.04189431883772) as geom, 15 as resolution UNION ALL
        
            -- null inputs
            SELECT 4 AS id, TRY_TO_GEOGRAPHY(NULL) AS geom, 5 as resolution UNION ALL
            SELECT 5 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, -1 as resolution UNION ALL
            SELECT 6 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, 20 as resolution UNION ALL
            SELECT 7 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, NULL as resolution
        )
        SELECT
            CAST(H3_FROMGEOGPOINT(geom, resolution) AS STRING) as h3_id
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(7);
    expect(rows.map((r) => r.H3_ID)).toEqual([
        '85283473fffffff',
        '8547732ffffffff',
        '8f2000000000000',
        null,
        null,
        null,
        null
    ]);
});

test('H3_FROMGEOGPOINT returns NULL with non POINT geographies', async () => {
    const query = `
        WITH inputs AS
        (
            SELECT 1 AS id, TO_GEOGRAPHY('LINESTRING(0 0, 10 10)') as geom, 5 as resolution UNION ALL
            SELECT 2 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 5 as resolution UNION ALL
            SELECT 3 AS id, TO_GEOGRAPHY('MULTIPOINT(0 0, 0 10, 10 10, 10 0, 0 0)') as geom, 5 as resolution
        )
        SELECT
            CAST(H3_FROMGEOGPOINT(geom, resolution) AS STRING) as h3_id
        FROM inputs
        ORDER BY id ASC
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(3);
    expect(rows.map((r) => r.H3_ID)).toEqual([
        null,
        null,
        null
    ]);
});