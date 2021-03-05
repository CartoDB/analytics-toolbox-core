const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_H3 = process.env.BQ_DATASET_H3;

describe('TOPARENT', () => {
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

    it ('TOPARENT works as expected with invalid data', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid UNION ALL
    SELECT 2 AS id, 0xff283473fffffff as hid
)
SELECT
    id,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.TOPARENT(hid, 1) as parent
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 2);
        assert.equal(rows[0].parent, null);
        assert.equal(rows[1].parent, null);
    });

    it ('Equivalent to previous resolution level', async () => {
    /* From h3-js tests:
        // NB: This test will not work with every hexagon, it has to be a location
        // that does not fall in the margin of error between the 7 children and
        // the parent's true boundaries at every resolution
     */
        const query = `
WITH ids AS
(
    SELECT
        ST_GEOGPOINT(-122.409290778685, 37.81331899988944) as point,
        resolution
    FROM UNNEST(GENERATE_ARRAY(1, 10, 1)) resolution
)
SELECT
    *
FROM ids
WHERE
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ST_ASH3(point, resolution) != \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.TOPARENT(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ST_ASH3(point, resolution + 1), resolution) OR
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ST_ASH3(point, resolution) != \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.TOPARENT(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ST_ASH3(point, resolution + 2), resolution)
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

}); /* TOPARENT integration tests */
