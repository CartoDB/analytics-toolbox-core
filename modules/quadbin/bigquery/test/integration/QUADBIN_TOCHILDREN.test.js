const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADBIN_TOCHILDREN should work', async () => {
    const query = 'SELECT TO_JSON_STRING(`@@BQ_PREFIX@@carto.QUADBIN_TOCHILDREN`(5209574053332910079, 5)) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('["5214064458820747263","5214073254913769471","5214068856867258367","5214077652960280575"]');
});

test('QUADBIN_TOCHILDREN should throw an error for negative resolution', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.QUADBIN_TOCHILDREN`(5209574053332910079, -1) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADBIN_TOCHILDREN should throw an error for resolution overflow', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.QUADBIN_TOCHILDREN`(5209574053332910079, 27) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADBIN_TOCHILDREN should throw an error for resolution smaller than the index', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.QUADBIN_TOCHILDREN`(5209574053332910079, 3) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});