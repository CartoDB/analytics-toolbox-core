const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADBIN_BBOX should work', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.QUADBIN_BBOX`(5209574053332910079) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual([22.5, -21.943045533438166, 45.0, 0.0]);
});