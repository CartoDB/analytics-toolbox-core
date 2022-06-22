const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_ISVALID should detect valid indexes', async () => {
    const query = 'SELECT QUADBIN_ISVALID(5209574053332910079) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual(true);
});

test('QUADBIN_ISVALID should detect invalid indexes', async () => {
    const query = 'SELECT QUADBIN_ISVALID(1234) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual(false);
});

test('QUADBIN_ISVALID should detect invalid indexes (trailing bits)', async () => {
    const query = 'SELECT QUADBIN_ISVALID(5209538868960821248) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual(false);
});