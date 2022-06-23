const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_TOZXY should work', async () => {
    const query = 'SELECT QUADBIN_TOZXY(5209574053332910079) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual({ 'z':4,'x':9,'y':8 });
});