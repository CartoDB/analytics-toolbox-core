const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_FROMLONGLAT should work', async () => {
    const query = 'SELECT CAST(QUADBIN_FROMLONGLAT(40.4168, -3.7038, 4) AS STRING) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual('5209574053332910079');
});