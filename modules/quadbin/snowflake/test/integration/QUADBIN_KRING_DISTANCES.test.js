const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_KRING_DISTANCES should work', async () => {
    const query = 'SELECT QUADBIN_KRING_DISTANCES(5209574053332910079, 1) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT.sort((a, b) => a.index - b.index)).toEqual([
        { 'distance':1,'index':5208043533147045887 },
        { 'distance':1,'index':5208061125333090303 },
        { 'distance':1,'index':5208113901891223551 },
        { 'distance':1,'index':5209556461146865663 },
        { 'distance':0,'index':5209574053332910079 },
        { 'distance':1,'index':5209626829891043327 },
        { 'distance':1,'index':5209609237704998911 },
        { 'distance':1,'index':5209662014263132159 },
        { 'distance':1,'index':5209591645518954495 }].sort((a, b) => a.index - b.index));
});