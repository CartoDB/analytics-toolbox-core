const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_FROMLONGLAT should work', async () => {
    const query = `
    WITH inputs AS (
        SELECT 1 AS ID, CAST(QUADBIN_FROMLONGLAT(40.4168, -3.7038, 4) AS STRING) AS OUTPUT
            UNION ALL SELECT 2, CAST(QUADBIN_FROMLONGLAT(0, 85.05112877980659, 26) AS STRING)
            UNION ALL SELECT 3, CAST(QUADBIN_FROMLONGLAT(0, 88, 26) AS STRING)
            UNION ALL SELECT 4, CAST(QUADBIN_FROMLONGLAT(0, 90, 26) AS STRING)
            UNION ALL SELECT 5, CAST(QUADBIN_FROMLONGLAT(0, -85.05112877980659, 26) AS STRING)
            UNION ALL SELECT 6, CAST(QUADBIN_FROMLONGLAT(0, -88, 26) AS STRING)
            UNION ALL SELECT 7, CAST(QUADBIN_FROMLONGLAT(0, -90, 26) AS STRING)
    )
    SELECT * FROM inputs ORDER BY id ASC`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(7);
    expect(rows[0].OUTPUT).toEqual('5209574053332910079');
    expect(rows[1].OUTPUT).toEqual('5306366260949286912');
    expect(rows[2].OUTPUT).toEqual('5306366260949286912');
    expect(rows[3].OUTPUT).toEqual('5306366260949286912');
    expect(rows[4].OUTPUT).toEqual('5309368660700867242');
    expect(rows[5].OUTPUT).toEqual('5309368660700867242');
    expect(rows[6].OUTPUT).toEqual('5309368660700867242');
});