const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_TOZXY should work', async () => {
    const query = 'SELECT TO_JSON_STRING(`@@BQ_DATASET@@.QUADBIN_TOZXY`(5209574053332910079)) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('{"z":4,"x":9,"y":8}');
});