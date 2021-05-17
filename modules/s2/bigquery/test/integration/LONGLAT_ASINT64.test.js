const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('LONGLAT_ASINT64 should work', async () => {
    const query = 'SELECT CAST(`@@BQ_PREFIX@@s2.LONGLAT_ASINT64`(-74.006, 40.7128, 12) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('-8520148382826627072');
});

test('LONGLAT_ASINT64 should fail with NULL argument', async () => {
    let query = 'SELECT `@@BQ_PREFIX@@s2.ST_BOUNDARY_FROMINT64`(NULL, 10, 5)';
    await expect(runQuery(query)).rejects.toThrow();
    query = 'SELECT `@@BQ_PREFIX@@s2.ST_BOUNDARY_FROMINT64`(13, NULL, 5)';
    await expect(runQuery(query)).rejects.toThrow();
    query = 'SELECT `@@BQ_PREFIX@@s2.ST_BOUNDARY_FROMINT64`(13, 10, NULL)';
    await expect(runQuery(query)).rejects.toThrow();
});