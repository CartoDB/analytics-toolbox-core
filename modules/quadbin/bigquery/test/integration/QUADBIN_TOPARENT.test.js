const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADBIN_TOPARENT should work', async () => {
    const query = 'SELECT CAST(`@@BQ_PREFIX@@carto.QUADBIN_TOPARENT`(5209574053332910079, 3) AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5205105638077628415');
});

test('QUADBIN_TOPARENT should throw an error for negative resolution', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.QUADBIN_TOPARENT`(5209574053332910079, -1) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADBIN_TOPARENT should throw an error for resolution overflow', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.QUADBIN_TOPARENT`(5209574053332910079, 27) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADBIN_TOPARENT should throw an error for resolution larger than the index', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.QUADBIN_TOPARENT`(5209574053332910079, 5) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});