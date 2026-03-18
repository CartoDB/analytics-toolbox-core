const { runQuery } = require('../../../common/test-utils');

test('S2_FROMTOKEN should work with full 16-char token', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.S2_FROMTOKEN`("89c25a3000000000") AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('-8520148382826627072');
});

test('S2_FROMTOKEN should work with standard short token (trailing zeros stripped)', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.S2_FROMTOKEN`("89c25a3") AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('-8520148382826627072');
});

test('S2_FROMTOKEN should work with face 0 cell (positive ID)', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.S2_FROMTOKEN`("0d423") AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('955378847514099712');
});

test('S2_FROMTOKEN roundtrip with S2_TOTOKEN should return original ID', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.S2_FROMTOKEN`(`@@BQ_DATASET@@.S2_TOTOKEN`(-8520148382826627072)) AS STRING) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('-8520148382826627072');
});