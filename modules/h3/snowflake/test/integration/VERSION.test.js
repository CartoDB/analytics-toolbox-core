const { runQuery } = require('../../../../../common/snowflake/test-utils');
const version = require('../../package.json').version;

test('VERSION returns the proper version', async () => {
    const query = 'SELECT @@SF_PREFIX@@h3.VERSION() as v';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].V).toEqual(version);
});