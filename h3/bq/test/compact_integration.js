const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_H3 = process.env.BQ_DATASET_H3;

describe('COMPACT / UNCOMPACT ', () => {
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

    it ('Work as expected with NULLish values', async () => {
        let query = `
SELECT 
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.COMPACT(NULL) as c,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.UNCOMPACT(NULL, 5) as u
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].c, []);
        assert.deepEqual(rows[0].u, []);

        query = `
        SELECT
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.COMPACT([]) as c,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.UNCOMPACT([], 5) as u
        `;
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].c, []);
        assert.deepEqual(rows[0].u, []);
    });

    it ('Work with polyfill arrays', async () => {
        const query = `
WITH poly AS
(
    SELECT \`${BQ_PROJECTID}.${BQ_DATASET_H3}\`.ST_ASH3_POLYFILL(ST_GEOGFROMTEXT('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))'), 9) AS v
)
SELECT
    ARRAY_LENGTH(v) AS original,
    ARRAY_LENGTH(\`${BQ_PROJECTID}.${BQ_DATASET_H3}\`.COMPACT(v)) AS compacted,
    ARRAY_LENGTH(\`${BQ_PROJECTID}.${BQ_DATASET_H3}\`.UNCOMPACT(\`${BQ_PROJECTID}.${BQ_DATASET_H3}\`.COMPACT(v), 9)) AS uncompacted
FROM poly
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].original, 1253);
        assert.equal(rows[0].compacted, 209);
        assert.equal(rows[0].uncompacted, 1253);
    });

}); /* COMPACT / UNCOMPACT integration tests */
