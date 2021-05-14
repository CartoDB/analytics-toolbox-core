const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('LONGLAT_ASID should work', async () => {
    const query = 'SELECT CAST(@@SF_PREFIX@@s2.LONGLAT_ASID(-74.006, 40.7128, 12) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].ID.toString()).toEqual('-8520148382826627072');
});

test('LONGLAT_ASID should fail with NULL argument', async () => {
    let query = 'SELECT @@SF_PREFIX@@s2.ST_BOUNDARY(NULL, 10, 5)';
    await expect(runQuery(query)).rejects.toThrow();
    query = 'SELECT @@SF_PREFIX@@s2.ST_BOUNDARY(13, NULL, 5)';
    await expect(runQuery(query)).rejects.toThrow();
    query = 'SELECT @@SF_PREFIX@@s2.ST_BOUNDARY(13, 10, NULL)';
    await expect(runQuery(query)).rejects.toThrow();
});