const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('PLACEKEY_ISVALID should work', async () => {
    const query = `
        SELECT PLACEKEY_ISVALID(placekey.value) AS valid
        FROM TABLE(FLATTEN(INPUT => PARSE_JSON('[
            NULL, "@abc", "abc-xyz", "abcxyz234", "abc-345@abc-234-xyz",
            "ebc-345@abc-234-xyz", "bcd-345@", "22-zzz@abc-234-xyz",
            "abc-234-xyz", "@abc-234-xyz", "bcd-2u4-xez",
            "zzz@abc-234-xyz", "222-zzz@abc-234-xyz"
        ]'))) AS placekey
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.VALID)).toEqual([
        false, false, false, false, false, false, false, false,
        true, true, true, true, true
    ]);
});