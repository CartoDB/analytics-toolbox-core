const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_PLACEKEY = process.env.BQ_DATASET_PLACEKEY;

describe('ISVALID', () => {
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

    it ('Works as expected', async () => {
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
    SELECT 8 AS id, '22-zzz@abc-234-xyz' as pk UNION ALL

    -- Valid parameters
    SELECT 9 AS id, 'abc-234-xyz' as pk UNION ALL
    SELECT 10 AS id, '@abc-234-xyz' as pk UNION ALL
    SELECT 11 AS id, 'bcd-2u4-xez' as pk UNION ALL
    SELECT 12 AS id, 'zzz@abc-234-xyz' as pk UNION ALL
    SELECT 13 AS id, '222-zzz@abc-234-xyz' as pk
)
SELECT
    id,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PLACEKEY}\`.ISVALID(pk) as valid
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 13);
        assert.equal(rows[0].valid, false);
        assert.equal(rows[1].valid, false);
        assert.equal(rows[2].valid, false);
        assert.equal(rows[3].valid, false);
        assert.equal(rows[4].valid, false);
        assert.equal(rows[5].valid, false);
        assert.equal(rows[6].valid, false);
        assert.equal(rows[7].valid, false);
        assert.equal(rows[8].valid, true);
        assert.equal(rows[9].valid, true);
        assert.equal(rows[10].valid, true);
        assert.equal(rows[11].valid, true);
        assert.equal(rows[12].valid, true);
    });

}); /* PLACEKEY_ISVALID integration tests */
