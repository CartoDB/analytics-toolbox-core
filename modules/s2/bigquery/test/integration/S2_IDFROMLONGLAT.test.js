const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('S2_IDFROMLONGLAT should work', async () => {
    const query = 'SELECT CAST(`@@BQ_PREFIX@@carto.S2_IDFROMLONGLAT`(-74.006, 40.7128, 12) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('-8520148382826627072');
});

test('S2_IDFROMLONGLAT should fail with NULL argument', async () => {
    let query = 'SELECT `@@BQ_PREFIX@@carto.S2_BOUNDARY`(NULL, 10, 5)';
    await expect(runQuery(query)).rejects.toThrow();
    query = 'SELECT `@@BQ_PREFIX@@carto.S2_BOUNDARY`(13, NULL, 5)';
    await expect(runQuery(query)).rejects.toThrow();
    query = 'SELECT `@@BQ_PREFIX@@carto.S2_BOUNDARY`(13, 10, NULL)';
    await expect(runQuery(query)).rejects.toThrow();
});