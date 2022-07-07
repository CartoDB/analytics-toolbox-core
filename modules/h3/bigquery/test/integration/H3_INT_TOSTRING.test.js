const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('Correctly converts H3 int to H3 string', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@carto.H3_INT_TOSTRING\`(599686042433355775) as strid
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].strid).toEqual('85283473fffffff');
});
