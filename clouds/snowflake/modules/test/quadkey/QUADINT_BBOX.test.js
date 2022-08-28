const { runQuery } = require('../../../common/test-utils');

test('QUADINT_BBOX should work', async () => {
    const query = `
        SELECT QUADINT_BBOX(VALUE) as bbox
        FROM LATERAL FLATTEN(input => ARRAY_CONSTRUCT(162, 12070922, 791040491538, 12960460429066265))
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.BBOX)).toEqual([
        [-90, 0, 0, 66.51326044311186],
        [-45, 44.84029065139799, -44.6484375, 45.08903556483103],
        [-45, 44.99976701918129, -44.99862670898438, 45.00073807829068],
        [-45, 44.99999461263668, -44.99998927116394, 45.00000219906962]
    ]);
});

test('QUADINT_BBOX should fail with NULL argument', async () => {
    const query = `
        SELECT QUADINT_BBOX(NULL)
    `;
    await expect(runQuery(query)).rejects.toThrow();
});