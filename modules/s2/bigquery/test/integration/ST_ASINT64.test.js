const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_ASINT64 should work', async () => {
    const query = 'SELECT CAST(`@@BQ_PREFIX@@s2.ST_ASINT64`(ST_GEOGPOINT(-74.006, 40.7128), 12) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('-8520148382826627072');
});