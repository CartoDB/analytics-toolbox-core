const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADBIN_FROMZXY should work', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.QUADBIN_FROMZXY`(z,x,y) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual();
});