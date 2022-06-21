const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('Example of running a query', async () => {
    const query = 'SELECT 123 as v';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].v).toEqual(123);
});