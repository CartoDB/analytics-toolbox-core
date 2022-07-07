const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('Correctly converts H3 string to H3 int', async () => {
    const query = `
        SELECT H3_STRING_TOINT('85283473fffffff') as intid
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].intid).toEqual(599686042433355775);
});
