const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_H3 = process.env.BQ_DATASET_H3;

describe('ISPENTAGON', () => {
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
    SELECT 1 AS id, NULL as hid UNION ALL
    SELECT 2 AS id, 'ff283473fffffff' as hid UNION ALL

    -- Valid parameters
                    -- Hex
    SELECT 3 AS id, '8928308280fffff' as hid UNION ALL
                    -- Pentagon
    SELECT 4 AS id, '821c07fffffffff' as hid
)
SELECT
    id,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ISPENTAGON(hid) as pent
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 4);
        assert.equal(rows[0].pent, false);
        assert.equal(rows[1].pent, false);
        assert.equal(rows[2].pent, false);
        assert.equal(rows[3].pent, true);
    });

}); /* ISPENTAGON integration tests */
