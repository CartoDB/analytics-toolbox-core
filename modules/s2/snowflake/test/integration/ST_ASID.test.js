const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('ST_ASID should work', async () => {
    const query = 'SELECT CAST(@@SF_PREFIX@@s2.ST_ASID(ST_POINT(-74.006, 40.7128), 12) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].ID.toString()).toEqual('-8520148382826627072');
});
