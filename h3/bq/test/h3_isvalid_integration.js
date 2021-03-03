const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_H3 = process.env.BQ_DATASET_H3;

describe('H3_ISVALID', () => {
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

    it ('ST_H3_BOUNDARY works as expected', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid UNION ALL
    SELECT 2 AS id, 0xff283473fffffff as hid UNION ALL

    -- Valid parameters
    SELECT 3 AS id, 0x85283473fffffff as hid UNION ALL
    SELECT 4 AS id, \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ST_ASH3(ST_GEOGPOINT(-122.0553238, 37.3615593), 5)
)
SELECT
    id,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.H3_ISVALID(hid) as valid
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 4);
        assert.equal(rows[0].valid, false);
        assert.equal(rows[1].valid, false);
        assert.equal(rows[2].valid, true);
        assert.equal(rows[3].valid, true);
    });

}); /* H3_ISVALID integration tests */
