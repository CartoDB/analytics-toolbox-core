const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_BOUNDARY functions should work', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@s2.ST_BOUNDARY\`(3209632993970749440) as boundary
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].boundary.value).toEqual('POLYGON((125.000260404646 -13.999959549589, 125.000260404646 -13.9996486905691, 124.999916074945 -13.9997052848802, 124.999916074945 -14.0000161450551, 125.000260404646 -13.999959549589))');
});

test('ST_BOUNDARY should fail with NULL argument', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@s2.ST_BOUNDARY\`(null)
    `;
    await expect(runQuery(query)).rejects.toThrow();
});
