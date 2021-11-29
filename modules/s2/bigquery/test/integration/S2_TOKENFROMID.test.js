const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('S2_TOKENFROMID should work', async () => {
    const query = 'SELECT CAST(`@@BQ_PREFIX@@s2.S2_TOKENFROMID`(-8520148382826627072) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('89c25a3000000000');
});