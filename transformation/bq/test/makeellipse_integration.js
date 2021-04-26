const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_TRANSFORMATION = process.env.BQ_DATASET_TRANSFORMATION;

describe('ST_MAKEELLIPSE integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_TRANSFORMATION) {
            throw "Missing BQ_DATASET_TRANSFORMATION env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('ST_MAKEELLIPSE should return NULL if any NULL mandatory argument', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATION}\`.ST_MAKEELLIPSE(NULL, 5, 3, -30, "miles", 80) as ellipse1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATION}\`.ST_MAKEELLIPSE(ST_GEOGPOINT(-73.9385,40.6643), NULL, 3, -30, "miles", 80) as ellipse2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATION}\`.ST_MAKEELLIPSE(ST_GEOGPOINT(-73.9385,40.6643), 5, NULL, -30, "miles", 80) as ellipse3`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].ellipse1, null);
        assert.equal(rows[0].ellipse2, null);
        assert.equal(rows[0].ellipse2, null);
    });

    it ('ST_MAKEELLIPSE default values should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATION}\`.ST_MAKEELLIPSE(ST_GEOGPOINT(-73.9385,40.6643), 5, 3, 0, "kilometers", 64) as defaultValue,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATION}\`.ST_MAKEELLIPSE(ST_GEOGPOINT(-73.9385,40.6643), 5, 3, NULL, NULL, NULL) as nullParam1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].nullParam1, rows[0].defaultValue);
    });
}); /* ST_MAKEELLIPSE integration tests */
