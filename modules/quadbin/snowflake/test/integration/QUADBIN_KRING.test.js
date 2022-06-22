const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_KRING should work', async () => {
    const query = 'SELECT QUADBIN_KRING(5209574053332910079, 1) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual([5208043533147045887,5208061125333090303,5208113901891223551,5209556461146865663,5209574053332910079,5209626829891043327,5209609237704998911,5209662014263132159,5209591645518954495]);
});