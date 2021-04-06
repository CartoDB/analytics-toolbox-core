const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_H3 = process.env.BQ_DATASET_H3;

describe('HEX', () => {
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

    it ('H3_FROMINT returns the proper INT64', async () => {
        const query = `
WITH inputs AS
(
    SELECT 1 AS id, ST_GEOGPOINT(-122.0553238, 37.3615593) as geom, 5 as resolution UNION ALL
    SELECT 2 AS id, ST_GEOGPOINT(-164.991559, 30.943387) as geom, 5 as resolution UNION ALL
    SELECT 3 AS id, ST_GEOGPOINT(71.52790329909925, 46.04189431883772) as geom, 15 as resolution UNION ALL
    SELECT 4 AS id, NULL AS geom, 5 as resolution
)
SELECT
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.H3_ASINT(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ST_ASH3(geom, resolution)) as h3_id
FROM inputs
ORDER BY id ASC`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 4);
        assert.equal(rows[0].h3_id, 599686042433355800);
        assert.equal(rows[1].h3_id, 600235711274156000);
        assert.equal(rows[2].h3_id, 644577696667402200);
        assert.equal(rows[3].h3_id, null);
    });

    it ('H3_ASINT returns the proper INT64', async () => {
        const query = `
WITH inputs AS
(
    SELECT 1 AS id, ST_GEOGPOINT(-122.0553238, 37.3615593) as geom, 5 as resolution UNION ALL
    SELECT 2 AS id, ST_GEOGPOINT(-164.991559, 30.943387) as geom, 5 as resolution UNION ALL
    SELECT 3 AS id, ST_GEOGPOINT(71.52790329909925, 46.04189431883772) as geom, 15 as resolution UNION ALL
    SELECT 4 AS id, NULL AS geom, 5 as resolution
)
SELECT
    *
FROM inputs
WHERE
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ST_ASH3(geom, resolution) !=
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.H3_FROMINT(
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.H3_ASINT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ST_ASH3(geom, resolution)))
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

}); /* HEX integration tests */
