const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_FROMGEOGPOINT should work', async () => {
    const query = 'SELECT CAST(QUADBIN_FROMGEOGPOINT(ST_POINT(40.4168, -3.7038), 4) AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5209574053332910079');
});