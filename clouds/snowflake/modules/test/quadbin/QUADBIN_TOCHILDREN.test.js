const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_TOCHILDREN should work', async () => {
    const query = 'SELECT ARRAY_TO_STRING(QUADBIN_TOCHILDREN(5209574053332910079, 5), \',\') AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    const out = rows[0].OUTPUT.split(',').sort().join(',')
    expect(rows[0].OUTPUT).toEqual('5214064458820747263,5214068856867258367,5214073254913769471,5214077652960280575');

});


test('QUADBIN_TOCHILDREN should throw an error for negative resolution', async () => {
    const query = 'SELECT QUADBIN_TOCHILDREN(5209574053332910079, -1) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADBIN_TOCHILDREN should throw an error for resolution overflow', async () => {
    const query = 'SELECT QUADBIN_TOCHILDREN(5209574053332910079, 27) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADBIN_TOCHILDREN should throw an error for resolution smaller than the index', async () => {
    const query = 'SELECT QUADBIN_TOCHILDREN(5209574053332910079, 3) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});