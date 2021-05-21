const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ID_FROMTOKEN should work', async () => {
    const query = 'SELECT CAST(`@@BQ_PREFIX@@s2.TOKEN_FROMID`(-8520148382826627072) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('89c25a3000000000');
});