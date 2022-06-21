const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADBIN_FROMZXY should work', async () => {
    const query = 'SELECT CAST(`@@BQ_PREFIX@@carto.QUADBIN_FROMZXY`(10, 200, 391) AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5233974874938015743');
});