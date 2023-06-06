const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_FROMLONGLAT should work', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_FROMLONGLAT`(40.4168, -3.7038, 4) AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5209574053332910079');
});

test('QUADBIN_FROMLONGLAT should return null if the input is null', async () => {
    const query = `SELECT
        CAST(\`@@BQ_DATASET@@.QUADBIN_FROMLONGLAT\`(NULL, -3.7038, 4) AS STRING) AS output0,
        CAST(\`@@BQ_DATASET@@.QUADBIN_FROMLONGLAT\`(40.4168, NULL, 4) AS STRING) AS output1,
        CAST(\`@@BQ_DATASET@@.QUADBIN_FROMLONGLAT\`(40.4168, -3.7038, NULL) AS STRING) AS output2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output0).toEqual(null);
    expect(rows[0].output1).toEqual(null);
    expect(rows[0].output2).toEqual(null);
});

test('QUADBIN_FROMLONGLAT should throw an error for negative resolution', async () => {
    const query = 'SELECT `@@BQ_DATASET@@.QUADBIN_FROMLONGLAT`(40.4168, -3.7038, -1) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADBIN_FROMLONGLAT should throw an error for resolution overflow', async () => {
    const query = 'SELECT `@@BQ_DATASET@@.QUADBIN_FROMLONGLAT`(40.4168, -3.7038, 27) AS output';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADBIN_FROMLONGLAT highest resolution', async () => {
    let query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_FROMLONGLAT`(-3.71219873428345, 40.413365349070865, 26) AS STRING) AS output';
    let rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5306319089810037072');

    query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_FROMLONGLAT`(40.413365349070865, -3.71219873428345, 26) AS STRING) AS output';
    rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5308641755410858449');

    query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_FROMLONGLAT`(0.0, 3.552713678800501e-15, 26) AS STRING) AS output';
    rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5308618060762972160');

    query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_FROMLONGLAT`(0.0, -3.552713678800501e-15, 26) AS STRING) AS output';
    rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5308618060762972160');

    query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_FROMLONGLAT`(-89.71219873428345, -84.413365349070865, 26) AS STRING) AS output';
    rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5308521992464067502');
});
