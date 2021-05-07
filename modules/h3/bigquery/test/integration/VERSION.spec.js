const { runQuery } = require('../common/utils');

test('VERSION returns the proper version', async () => {
    const query = 'SELECT %PROJECT%.%DATASET%.VERSION() as v';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].v).toEqual(require('../../package.json').version);
});