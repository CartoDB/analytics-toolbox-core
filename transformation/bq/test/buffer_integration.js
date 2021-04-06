const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_TRANSFORMATION = process.env.BQ_DATASET_TRANSFORMATION;

describe('ST_BUFFER integration tests', () => {
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

    //TODO PENDING TO ADD TESTS
    /*it ('ST_BUFFER should reject quadints at zoom 0', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATION}\`.TOPARENT(0,0)`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });
    */

}); /* TRANFORMATION integration tests */
