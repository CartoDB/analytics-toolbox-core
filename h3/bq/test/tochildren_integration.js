const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_H3 = process.env.BQ_DATASET_H3;

describe('TOCHILDREN', () => {
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

    it ('TOCHILDREN works as expected with invalid data', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid UNION ALL
    SELECT 2 AS id, 0xff283473fffffff as hid
)
SELECT
    id,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.TOCHILDREN(hid, 1) as parent
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 2);
        assert.deepEqual(rows[0].parent, []);
        assert.deepEqual(rows[1].parent, []);
    });

    it ('List children correctly', async () => {
        const query = `
WITH ids AS
(
    SELECT
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ST_ASH3(ST_GEOGPOINT(-122.409290778685, 37.81331899988944), 7) AS hid
)
SELECT
    ARRAY_LENGTH(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.TOCHILDREN(hid, 8)) AS length_children,
    ARRAY_LENGTH(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.TOCHILDREN(hid, 9)) AS length_grandchildren
FROM ids
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].length_children, 7);
        assert.equal(rows[0].length_grandchildren, 49);
    });

    it ('Same resolution lists self', async () => {
        const query = `
WITH ids AS
(
    SELECT 608692970266296319 as hid
)
SELECT
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.TOCHILDREN(hid, 7) AS self_children
FROM ids
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].self_children, [ 608692970266296319 ]);
    });

    it ('Coarser resolution returns empty array', async () => {
        const query = `
WITH ids AS
(
    SELECT
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ST_ASH3(ST_GEOGPOINT(-122.409290778685, 37.81331899988944), 7) AS hid
)
SELECT
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.TOCHILDREN(hid, 6) AS top_children
FROM ids
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].top_children, [ ]);
    });

}); /* TOCHILDREN integration tests */
