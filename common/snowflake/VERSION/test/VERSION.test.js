const { runQuery } = require('../../../test-utils');

test('VERSION returns the proper version', async () => {
    const query = 'SELECT VERSION() as v';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].V).toEqual('1.0.0');
});