const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_KRING_DISTANCES should work', async () => {
    const query = 'SELECT ARRAY_TO_STRING(QUADBIN_KRING_DISTANCES(5209574053332910079, 1), \',\') AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual('{"distance":1,"index":5208043533147045887},{"distance":1,"index":5209556461146865663},{"distance":1,"index":5209591645518954495},{"distance":1,"index":5208061125333090303},{"distance":0,"index":5209574053332910079},{"distance":1,"index":5209609237704998911},{"distance":1,"index":5208113901891223551},{"distance":1,"index":5209626829891043327},{"distance":1,"index":5209662014263132159}');

});