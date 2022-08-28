const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_CENTER should work', async () => {
    const query = 'SELECT QUADBIN_CENTER(5209574053332910079) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual({ 'coordinates': [33.75, -11.17840187371178], 'type': 'Point' }
    );
});