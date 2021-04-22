const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_TRANSFORMATION = process.env.BQ_DATASET_TRANSFORMATION;

describe('ST_GREATCIRCLE integration tests', () => {
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

    it ('ST_GREATCIRCLE should return NULL if any NULL mandatory argument', async () => {
        let feature = {
            "type": "Point",
            "coordinates": [-100, 50]  
        };
        featureJSON = JSON.stringify(feature);
    
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATION}\`.ST_GREATCIRCLE(NULL, ST_GEOGPOINT(-73.9385,40.6643), 20) as greatcircle1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATION}\`.ST_GREATCIRCLE(ST_GEOGPOINT(-3.70325,40.4167), NULL, 20) as greatcircle2`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].greatcircle1, null);
        assert.equal(rows[0].greatcircle2, null);
    });
}); /* ST_GREATCIRCLE integration tests */
