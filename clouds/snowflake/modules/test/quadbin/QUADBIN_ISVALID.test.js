const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_ISVALID should detect valid indexes', async () => {
    const query = 'SELECT QUADBIN_ISVALID(5209574053332910079) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(true);
});

test('QUADBIN_ISVALID should detect invalid indexes', async () => {
    const query = 'SELECT QUADBIN_ISVALID(1234) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(false);
});

test('QUADBIN_ISVALID should detect invalid indexes (trailing bits)', async () => {
    const query = 'SELECT QUADBIN_ISVALID(5209538868960821248) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(false);
});