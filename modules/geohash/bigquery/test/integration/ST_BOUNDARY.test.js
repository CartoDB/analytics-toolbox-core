const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_BOUNDARY should work', async () => {
    const query = 'SELECT ST_GEOGASTEXT(`@@BQ_PREFIX@@geohash.ST_BOUNDARY`(\'ezrq\')) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual('POLYGON((-1.0546875 41.8359375, -0.703125 41.8359375, -0.703125 42.01171875, -1.0546875 42.01171875, -1.0546875 41.8359375))');
    expect(rows[0].output).toEqual();
});