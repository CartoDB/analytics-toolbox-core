const { runQuery } = require('../../../../../common/bigquery/test-utils');
const version = require('../../package.json').version;

test('VERSION returns the proper version', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@transformations.VERSION`() as v';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].v).toEqual(version);
});
