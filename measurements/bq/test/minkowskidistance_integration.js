const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_MEASUREMENTS = process.env.BQ_DATASET_MEASUREMENTS;

describe('ST_MINKOWSKIDISTANCE integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_MEASUREMENTS) {
            throw "Missing BQ_DATASET_MEASUREMENTS env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('ST_MINKOWSKIDISTANCE should return NULL if any NULL mandatory argument', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_MINKOWSKIDISTANCE(NULL, 2) as minkowskidistance1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].minkowskidistance1, []);
    });

    it ('ST_MINKOWSKIDISTANCE default values should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_MINKOWSKIDISTANCE([ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-5.70325 ,40.4167)], 2) as defaultValue,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_MINKOWSKIDISTANCE([ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-5.70325 ,40.4167)], NULL) as nullParam1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].nullParam1, rows[0].defaultValue);
    });
}); /* ST_MINKOWSKIDISTANCE integration tests */
