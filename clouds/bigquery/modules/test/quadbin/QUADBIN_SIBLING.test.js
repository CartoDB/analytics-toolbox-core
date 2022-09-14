const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_SIBLING up should work', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_SIBLING`(5209574053332910079, \'up\') AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5208061125333090303');
});

test('QUADBIN_SIBLING down should work', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_SIBLING`(5209574053332910079, \'down\') AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5209609237704998911');
});

test('QUADBIN_SIBLING left should work', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_SIBLING`(5209574053332910079, \'left\') AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5209556461146865663');
});

test('QUADBIN_SIBLING right should work', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_SIBLING`(5209574053332910079, \'right\') AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5209626829891043327');
});

test('QUADBIN_SIBLING should return null if the sibling does not exists', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_SIBLING`(5192650370358181887, \'up\') AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual(null);
});

test('QUADBIN_SIBLING wrong should throw an error', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_SIBLING`(5209574053332910079, \'wrong\') AS STRING) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});