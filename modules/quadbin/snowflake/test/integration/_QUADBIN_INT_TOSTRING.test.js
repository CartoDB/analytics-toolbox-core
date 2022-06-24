const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_INT_TOSTRING should work', async () => {
    const query = 'SELECT _QUADBIN_INT_TOSTRING(5209574053332910079) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual('484C1FFFFFFFFFFF');
});