const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADBIN_INT_TOSTRING should work', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.__QUADBIN_INT_TOSTRING`(5209574053332910079) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('484c1fffffffffff');
});