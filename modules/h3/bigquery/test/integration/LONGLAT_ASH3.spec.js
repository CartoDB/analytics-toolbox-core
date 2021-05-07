const { runQuery } = require('../common/utils');

test('ST_ASH3 returns the proper INT64', async () => {
    const query = `
        WITH inputs AS
        (
            SELECT 1 AS id, -122.0553238 as longitude, 37.3615593 as latitude, 5 as resolution UNION ALL
            SELECT 2 AS id, -164.991559 as longitude, 30.943387 as latitude, 5 as resolution UNION ALL
            SELECT 3 AS id, 71.52790329909925 as longitude, 46.04189431883772 as latitude, 15 as resolution UNION ALL
        
            -- null inputs
            SELECT 4 AS id, NULL as longitude, 37.3615593 as latitude, 5 as resolution UNION ALL
            SELECT 5 AS id, -122.0553238 as longitude, NULL as latitude, 5 as resolution UNION ALL
            SELECT 6 AS id, -122.0553238 as longitude, 37.3615593 as latitude, NULL as resolution UNION ALL
        
            -- world wrapping
            SELECT 7 AS id, -122.0553238 + 360 as longitude, 37.3615593 as latitude, 5 as resolution UNION ALL
            SELECT 8 AS id, -122.0553238 as longitude, 37.3615593 + 360 as latitude, 5 as resolution
        )
        SELECT
            CAST(%PROJECT%.%DATASET%.LONGLAT_ASH3(longitude, latitude, resolution) AS STRING) as h3_id
        FROM inputs
        ORDER BY id ASC
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(8);
    expect(rows.map((r) => r.h3_id)).toEqual([
        '85283473fffffff',
        '8547732ffffffff',
        '8f2000000000000',
        null,
        null,
        null,
        '85283473fffffff',
        '85283473fffffff'
    ]);
});
