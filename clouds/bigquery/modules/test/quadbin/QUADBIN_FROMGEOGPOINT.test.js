const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_FROMGEOGPOINT should work', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_FROMGEOGPOINT`(ST_GEOGPOINT(40.4168, -3.7038), 4) AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5209574053332910079');
});