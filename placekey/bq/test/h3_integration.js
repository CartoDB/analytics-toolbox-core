const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_PLACEKEY = process.env.BQ_DATASET_PLACEKEY;

describe('Conversion to h3', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_PLACEKEY) {
            throw "Missing BQ_DATASET_PLACEKEY env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('PLACEKEY_ASH3 Returns null with invalid input', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as pk UNION ALL
    SELECT 2 AS id, '@abc' as pk UNION ALL
    SELECT 3 AS id, 'abc-xyz' as pk UNION ALL
    SELECT 4 AS id, 'abcxyz234' as pk UNION ALL
    SELECT 5 AS id, 'abc-345@abc-234-xyz' as pk UNION ALL
    SELECT 6 AS id, 'ebc-345@abc-234-xyz' as pk UNION ALL
    SELECT 7 AS id, 'bcd-345@' as pk UNION ALL
    SELECT 8 AS id, '22-zzz@abc-234-xyz' as pk
)
SELECT
    id,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PLACEKEY}\`.PLACEKEY_ASH3(pk) as h3
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 8);
        assert.equal(rows[0].h3, null);
        assert.equal(rows[1].h3, null);
        assert.equal(rows[2].h3, null);
        assert.equal(rows[3].h3, null);
        assert.equal(rows[4].h3, null);
        assert.equal(rows[5].h3, null);
        assert.equal(rows[6].h3, null);
        assert.equal(rows[7].h3, null);
    });

    it ('H3_ASPLACEKEY Returns null with invalid input', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid UNION ALL
    SELECT 2 AS id, 0xff283473fffffff as hid
)
SELECT
    id,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PLACEKEY}\`.H3_ASPLACEKEY(hid) as placekey
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 2);
        assert.equal(rows[0].placekey, null);
        assert.equal(rows[1].placekey, null);
    });

    it ('PLACEKEY_ASH3 and H3_ASPLACEKEY work as expected', async () => {
        const query = `
WITH ids AS
(
    SELECT 1 AS id, '@c6z-c2g-dgk' AS pk, 0x8a62e9d08a1ffff AS h3 UNION ALL
    SELECT 2 AS id, '@63m-vc4-z75' AS pk, 0x8a2a9c580577fff AS h3 UNION ALL
    SELECT 3 AS id, '@7qg-xf9-j5f' AS pk, 0x8a3c9ea2bd4ffff AS h3 UNION ALL
    SELECT 4 AS id, '@bhm-9m8-gtv' AS pk, 0x8a5b4c1047b7fff AS h3 UNION ALL
    SELECT 5 AS id, '@h5z-gcq-kvf' AS pk, 0x8a8e8116a6d7fff AS h3 UNION ALL
    SELECT 6 AS id, '@7v4-m2p-3t9' AS pk, 0x8a3e0ba6659ffff AS h3 UNION ALL
    SELECT 7 AS id, '@hvb-5d7-92k' AS pk, 0x8a961652a407fff AS h3 UNION ALL
    SELECT 8 AS id, '@ab2-k43-xqz' AS pk, 0x8a01262c914ffff AS h3 UNION ALL
    SELECT 9 AS id, '@adk-f8f-dn5' AS pk, 621534447861465087 AS h3 UNION ALL
    SELECT 10 AS id, '@jpx-58g-p9z' AS pk, 624300196419731455 AS h3 UNION ALL
    SELECT 11 AS id, '@4dd-yfx-6rk' AS pk, 621920217372721151 AS h3 UNION ALL
    SELECT 12 AS id, '@crb-3nn-zzz' AS pk, 623342631588003839 AS h3
)
SELECT
    *
FROM ids
WHERE
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PLACEKEY}\`.PLACEKEY_ASH3(pk) != h3 OR
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PLACEKEY}\`.H3_ASPLACEKEY(h3) != pk
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

}); /* h3 integration tests */
