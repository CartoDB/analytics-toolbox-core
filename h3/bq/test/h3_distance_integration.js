const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_H3 = process.env.BQ_DATASET_H3;

describe('H3_DISTANCE', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_H3) {
            throw "Missing BQ_DATASET_H3 env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('Works as expected', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid1, 0x85283473fffffff AS hid2 UNION ALL
    SELECT 2 AS id, 0xff283473fffffff as hid1, 0x85283473fffffff AS hid2 UNION ALL
    SELECT 3 AS id, 0x85283473fffffff as hid1, NULL AS hid2 UNION ALL
    SELECT 4 AS id, 0x85283473fffffff as hid1, 0xff283473fffffff AS hid2

    -- Valid parameters
    -- PENDING TO BE DONE BASED ON KRING
)
SELECT
    id,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.H3_DISTANCE(hid1, hid2) as distance
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 4);
        assert.equal(rows[0].distance, null);
        assert.equal(rows[1].distance, null);
        assert.equal(rows[2].distance, null);
        assert.equal(rows[3].distance, null);
    });

}); /* H3_DISTANCE integration tests */
