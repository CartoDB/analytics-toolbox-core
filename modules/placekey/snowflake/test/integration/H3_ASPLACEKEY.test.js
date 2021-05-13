const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('H3_ASPLACEKEY should work', async () => {
    const query = `
        SELECT @@SF_PREFIX@@placekey.H3_ASPLACEKEY(h3.value) AS placekey
        FROM TABLE(FLATTEN(INPUT => PARSE_JSON('[
            "8a62e9d08a1ffff", "8a2a9c580577fff", "8a3c9ea2bd4ffff", "8a5b4c1047b7fff",
            "8a8e8116a6d7fff", "8a3e0ba6659ffff", "8a961652a407fff", "8a01262c914ffff"
        ]'))) AS h3
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.PLACEKEY)).toEqual([
        '@c6z-c2g-dgk', '@63m-vc4-z75', '@7qg-xf9-j5f', '@bhm-9m8-gtv',
        '@h5z-gcq-kvf', '@7v4-m2p-3t9', '@hvb-5d7-92k', '@ab2-k43-xqz' 
    ]);
});

test('H3_ASPLACEKEY returns null with invalid input', async () => {
    const query = `
        SELECT @@SF_PREFIX@@placekey.H3_ASPLACEKEY(h3.value) AS placekey
        FROM TABLE(FLATTEN(INPUT => PARSE_JSON('[
            NULL, "ff283473fffffff"
        ]'))) AS h3
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.PLACEKEY)).toEqual([
        null, null
    ]);
});
