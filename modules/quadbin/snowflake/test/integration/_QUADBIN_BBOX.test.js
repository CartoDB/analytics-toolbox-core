const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('_QUADBIN_BBOX should work', async () => {
    const query = 'SELECT _QUADBIN_BBOX(5209574053332910079) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual([22.5, -21.94304553343817, 45.0, 0.0]);
});