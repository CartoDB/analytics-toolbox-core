const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_MEASUREMENT = process.env.BQ_DATASET_MEASUREMENT;

describe('ST_ANGLE integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_MEASUREMENT) {
            throw "Missing BQ_DATASET_MEASUREMENT env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('ST_ANGLE should return NULL if any NULL mandatory argument', async () => {
        let feature = {
            "type": "Point",
            "coordinates": [-100, 50]  
        };
        featureJSON = JSON.stringify(feature);
    
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENT}\`.ST_ANGLE(NULL, ST_GEOGPOINT(-4.70325 ,10.4167), ST_GEOGPOINT(-5.70325 ,40.4167), false) as angle1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENT}\`.ST_ANGLE(ST_GEOGPOINT(-3.70325 ,40.4167), NULL, ST_GEOGPOINT(-5.70325 ,40.4167), false) as angle2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENT}\`.ST_ANGLE(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,10.4167), NULL, false) as angle3`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].angle1, null);
        assert.equal(rows[0].angle2, null);
        assert.equal(rows[0].angle3, null);
    });
}); /* ST_ANGLE integration tests */
