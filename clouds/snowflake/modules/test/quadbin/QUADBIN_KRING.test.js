const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_KRING should work', async () => {
    const query = 'SELECT ARRAY_TO_STRING(QUADBIN_KRING(5209574053332910079, 1), \',\') AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(
        '5208043533147045887,5209556461146865663,5209591645518954495,5208061125333090303,5209574053332910079,5209609237704998911,5208113901891223551,5209626829891043327,5209662014263132159');
});