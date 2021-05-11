const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ISVALID should work', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@placekey.ISVALID\`(placekey) as valid
        FROM UNNEST([
            NULL, '@abc', 'abc-xyz', 'abcxyz234', 'abc-345@abc-234-xyz',
            'ebc-345@abc-234-xyz', 'bcd-345@', '22-zzz@abc-234-xyz',
            'abc-234-xyz', '@abc-234-xyz', 'bcd-2u4-xez',
            'zzz@abc-234-xyz', '222-zzz@abc-234-xyz'
        ]) as placekey
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.valid)).toEqual([
        false, false, false, false, false, false, false, false,
        true, true, true, true, true
    ]);
});
