const { runQuery } = require('../../../common/test-utils');

test('__QUADBIN_STRING_TOINT should work', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.__QUADBIN_STRING_TOINT`(\'484c1fffffffffff\') AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5209574053332910079');
});