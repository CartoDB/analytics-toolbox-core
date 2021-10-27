const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('PLACEKEY_ASH3 should work', async () => {
    const query = `
        SELECT PLACEKEY_ASH3(placekey.value) AS h3
        FROM TABLE(FLATTEN(INPUT => PARSE_JSON('[
            "@c6z-c2g-dgk", "@63m-vc4-z75", "@7qg-xf9-j5f", "@bhm-9m8-gtv",
            "@h5z-gcq-kvf", "@7v4-m2p-3t9", "@hvb-5d7-92k", "@ab2-k43-xqz"
        ]'))) AS placekey
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.H3)).toEqual([
        '8a62e9d08a1ffff', '8a2a9c580577fff', '8a3c9ea2bd4ffff', '8a5b4c1047b7fff',
        '8a8e8116a6d7fff', '8a3e0ba6659ffff', '8a961652a407fff', '8a01262c914ffff'
    ]);
});

test('PLACEKEY_ASH3 returns null with invalid input', async () => {
    const query = `
        SELECT PLACEKEY_ASH3(placekey.value) AS h3
        FROM TABLE(FLATTEN(INPUT => PARSE_JSON('[
            NULL, "@abc", "abc-xyz", "abcxyz234", "abc-345@abc-234-xyz",
            "ebc-345@abc-234-xyz", "bcd-345@", "22-zzz@abc-234-xyz"
        ]'))) AS placekey
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.H3)).toEqual([
        null, null, null, null, null, null, null, null
    ]);
});