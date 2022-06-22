const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_CENTER should work', async () => {
    const query = 'SELECT QUADBIN_CENTER(5209574053332910079) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output.value).toEqual('POINT(33.75 -11.1784018737118)');
});