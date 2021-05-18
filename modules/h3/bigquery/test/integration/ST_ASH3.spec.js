const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_ASH3 returns the proper INT64', async () => {
    const query = `
        WITH inputs AS
        (
            SELECT 1 AS id, ST_GEOGPOINT(-122.0553238, 37.3615593) as geom, 5 as resolution UNION ALL
            SELECT 2 AS id, ST_GEOGPOINT(-164.991559, 30.943387) as geom, 5 as resolution UNION ALL
            SELECT 3 AS id, ST_GEOGPOINT(71.52790329909925, 46.04189431883772) as geom, 15 as resolution UNION ALL

            -- null inputs
            SELECT 4 AS id, NULL AS geom, 5 as resolution UNION ALL
            SELECT 5 AS id, ST_GEOGPOINT(-122.0553238, 37.3615593) as geom, -1 as resolution UNION ALL
            SELECT 6 AS id, ST_GEOGPOINT(-122.0553238, 37.3615593) as geom, 20 as resolution UNION ALL
            SELECT 7 AS id, ST_GEOGPOINT(-122.0553238, 37.3615593) as geom, NULL as resolution
        )
        SELECT CAST(\`@@BQ_PREFIX@@h3.ST_ASH3\`(geom, resolution) AS STRING) as h3_id
        FROM inputs
        ORDER BY id ASC
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(7);
    expect(rows.map((r) => r.h3_id)).toEqual([
        '85283473fffffff',
        '8547732ffffffff',
        '8f2000000000000',
        null,
        null,
        null,
        null
    ]);
});

test('ST_ASH3 returns NULL with non POINT geographies', async () => {
    const query = `
        WITH inputs AS
        (
            SELECT 1 AS id, ST_GEOGFROMTEXT('LINESTRING(0 0, 10 10)') as geom, 5 as resolution UNION ALL
            SELECT 2 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 5 as resolution UNION ALL
            SELECT 3 AS id, ST_GEOGFROMTEXT('MULTIPOINT(0 0, 0 10, 10 10, 10 0, 0 0)') as geom, 5 as resolution
        )
        SELECT CAST(\`@@BQ_PREFIX@@h3.ST_ASH3\`(geom, resolution) AS STRING) as h3_id
        FROM inputs
        ORDER BY id ASC
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(3);
    expect(rows.map((r) => r.h3_id)).toEqual([
        null,
        null,
        null
    ]);
});