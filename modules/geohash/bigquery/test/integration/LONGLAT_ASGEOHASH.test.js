const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('LONGLAT_ASGEOHASH should work', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@geohash.LONGLAT_ASGEOHASH`(longitude, latitude, resolution) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual();
});