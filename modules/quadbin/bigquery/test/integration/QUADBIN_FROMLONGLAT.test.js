const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADBIN_FROMLONGLAT should work', async () => {
    const query = 'SELECT CAST(`@@BQ_PREFIX@@carto.QUADBIN_FROMLONGLAT`(40.4168, -3.7038, 4) AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5209574053332910079');
});

test('QUADBIN_FROMLONGLAT should return null if the input is null', async () => {
    const query = `SELECT
        CAST(\`@@BQ_PREFIX@@carto.QUADBIN_FROMLONGLAT\`(NULL, -3.7038, 4) AS STRING) AS output0,
        CAST(\`@@BQ_PREFIX@@carto.QUADBIN_FROMLONGLAT\`(40.4168, NULL, 4) AS STRING) AS output1,
        CAST(\`@@BQ_PREFIX@@carto.QUADBIN_FROMLONGLAT\`(40.4168, -3.7038, NULL) AS STRING) AS output2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output0).toEqual(null);
    expect(rows[0].output1).toEqual(null);
    expect(rows[0].output2).toEqual(null);
});

test('QUADBIN_FROMLONGLAT should throw an error for negative resolution', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.QUADBIN_FROMLONGLAT`(40.4168, -3.7038, -1) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADBIN_FROMLONGLAT should throw an error for resolution overflow', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.QUADBIN_FROMLONGLAT`(40.4168, -3.7038, 27) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});