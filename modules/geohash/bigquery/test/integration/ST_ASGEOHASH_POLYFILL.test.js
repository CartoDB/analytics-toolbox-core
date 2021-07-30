const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_ASGEOHASH_POLYFILL should work', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@geohash.ST_ASGEOHASH_POLYFILL`(geog, resolution) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual();
});
