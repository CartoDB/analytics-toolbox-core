const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADINT_BBOX should work', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@carto.QUADINT_BBOX\`(quadint) as bbox
        FROM UNNEST([162, 12070922, 791040491538, 12960460429066265]) as quadint
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.bbox)).toEqual([
        [-90, 0, 0, 66.51326044311185],
        [-45, 44.840290651398, -44.6484375, 45.08903556483104],
        [-45, 44.999767019181284, -44.998626708984375, 45.00073807829067],
        [-45, 44.999994612636684, -44.99998927116394, 45.00000219906963]
    ]);
});

test('QUADINT_BBOX should fail with NULL argument', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@carto.QUADINT_BBOX\`(NULL)
    `;
    await expect(runQuery(query)).rejects.toThrow();
});