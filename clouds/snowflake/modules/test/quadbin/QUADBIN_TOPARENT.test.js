const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_TOPARENT should work', async () => {
    const query = 'SELECT CAST(QUADBIN_TOPARENT(5209574053332910079, 3) AS STRING) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual('5205105638077628415');
});