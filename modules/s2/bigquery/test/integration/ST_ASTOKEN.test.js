const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_ASTOKEN should work', async () => {
    const query = 'SELECT CAST(`@@BQ_PREFIX@@s2.ST_ASTOKEN`(ST_GEOGPOINT(-74.006, 40.7128), 12) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('89c25a3000000000');
});