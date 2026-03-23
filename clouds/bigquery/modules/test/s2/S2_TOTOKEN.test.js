const { runQuery } = require('../../../common/test-utils');

test('S2_TOTOKEN should work with face 4/5 cell (negative ID)', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.S2_TOTOKEN`(-8520148382826627072) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('89c25a3');
});

test('S2_TOTOKEN should work with face 0 cell (positive ID)', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.S2_TOTOKEN`(955378847514099712) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('0d423');
});

test('S2_TOTOKEN roundtrip with S2_FROMTOKEN should return original token', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.S2_TOTOKEN`(`@@BQ_DATASET@@.S2_FROMTOKEN`("89c25a3")) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('89c25a3');
});