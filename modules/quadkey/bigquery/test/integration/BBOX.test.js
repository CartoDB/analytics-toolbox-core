const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('BBOX should work', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@quadkey.BBOX\`(quadint) as bbox
        FROM UNNEST([162, 12070922, 791040491538, 12960460429066265]) as quadint
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.bbox)).toEqual([
        [-90, 0, 0, 66.51326044311186],
        [-45, 44.840290651397986, -44.6484375, 45.08903556483103],
        [-45, 44.99976701918129, -44.998626708984375, 45.00073807829068],
        [-45, 44.999994612636684, -44.99998927116394, 45.00000219906962]
    ]);
});

test('BBOX should fail with NULL argument', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@quadkey.BBOX\`(NULL)
    `;
    await expect(runQuery(query)).rejects.toThrow();
});
