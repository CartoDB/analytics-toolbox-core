const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_FROMZXY should work', async () => {
    const query = 'SELECT CAST(QUADBIN_FROMZXY(4, 9, 8) AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5209574053332910079');
});