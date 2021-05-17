const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('INT64_FROMTOKEN should work', async () => {
    const query = 'SELECT CAST(`@@BQ_PREFIX@@s2.INT64_FROMTOKEN`("89c25a3000000000") AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('-8520148382826627072');
});