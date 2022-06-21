const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('__ZXY_TO_QUADBIN should work', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.__ZXY_TO_QUADBIN`(z, x, y) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual();
});