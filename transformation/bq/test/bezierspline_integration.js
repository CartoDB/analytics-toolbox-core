const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_TRANSFORMATION = process.env.BQ_DATASET_TRANSFORMATION;

describe('ST_BEZIERSPLINE integration tests', () => {
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

    it ('ST_BEZIERSPLINE should return NULL if any NULL mandatory argument', async () => {
        let feature = {
            "type": "Point",
            "coordinates": [-100, 50]  
        };
        featureJSON = JSON.stringify(feature);
    
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATION}\`.ST_BEZIERSPLINE(NULL, 0.9) as bezierspline1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].bezierspline1, null);
    });
}); /* ST_BEZIERSPLINE integration tests */
