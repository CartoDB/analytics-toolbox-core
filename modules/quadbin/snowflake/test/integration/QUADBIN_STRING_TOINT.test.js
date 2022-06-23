const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_STRING_TOINT should work', async () => {
    const query = 'SELECT CAST(QUADBIN_STRING_TOINT(\'484c1fffffffffff\') AS STRING) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual('5209574053332910079');
});