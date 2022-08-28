const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_RESOLUTION should work', async () => {
    const query = 'SELECT QUADBIN_RESOLUTION(5209574053332910079) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(4);
});