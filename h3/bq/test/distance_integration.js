const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_H3 = process.env.BQ_DATASET_H3;

describe('DISTANCE', () => {
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

    it ('Works as expected with invalid input', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid1, '85283473fffffff' AS hid2 UNION ALL
    SELECT 2 AS id, 'ff283473fffffff' as hid1, '85283473fffffff' AS hid2 UNION ALL
    SELECT 3 AS id, '85283473fffffff' as hid1, NULL AS hid2 UNION ALL
    SELECT 4 AS id, '85283473fffffff' as hid1, 'ff283473fffffff' AS hid2 UNION ALL

    -- Self
    SELECT 5 AS id, '8928308280fffff' as hid1, '8928308280fffff' as hid2
)
SELECT
    id,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.DISTANCE(hid1, hid2) as distance
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 5);
        assert.equal(rows[0].distance, null);
        assert.equal(rows[1].distance, null);
        assert.equal(rows[2].distance, null);
        assert.equal(rows[3].distance, null);
        assert.equal(rows[4].distance, 0);
    });

    it ('Works as expected with valid input', async () => {
        const query = `
WITH distances AS
(
    SELECT distance FROM UNNEST(GENERATE_ARRAY(0, 4, 1)) distance
),
ids AS
(
    SELECT
        distance,
        '8928308280fffff' as hid1,
        hid2
    FROM
        distances,
        UNNEST (\`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.HEXRING('8928308280fffff', distance)) hid2
)
SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.DISTANCE(hid1, hid2) as calculated_distance, *
FROM ids
WHERE \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.DISTANCE(hid1, hid2) != distance;
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

}); /* DISTANCE integration tests */
