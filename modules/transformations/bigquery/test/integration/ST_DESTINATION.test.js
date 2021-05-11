const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_TRANSFORMATIONS = process.env.BQ_DATASET_TRANSFORMATIONS;

describe('ST_DESTINATION integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_TRANSFORMATIONS) {
            throw "Missing BQ_DATASET_TRANSFORMATIONS env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('ST_DESTINATION should work', async () => {
        const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_DESTINATION(ST_GEOGPOINT(0, 0), 10, 90, "kilometers") as destination1,
        \`@@BQ_PREFIX@@transformations.ST_DESTINATION(ST_GEOGPOINT(-3.70325, 40.4167), 5, 45, "kilometers") as destination2,
        \`@@BQ_PREFIX@@transformations.ST_DESTINATION(ST_GEOGPOINT(-43.7625, -20), 150, -20, "miles") as destination3`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].destination1.value, 'POINT(0.0899320363724538 5.50674676307584e-18)');
        assert.equal(rows[0].destination2.value, 'POINT(-3.66146785439614 40.4484882583202)');
        assert.equal(rows[0].destination3.value, 'POINT(-44.5428812187219 -17.958278944262)');
    });

    it ('ST_DESTINATION should return NULL if any NULL mandatory argument', async () => {
        const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_DESTINATION(NULL, 10, 45, "miles") as destination1,
        \`@@BQ_PREFIX@@transformations.ST_DESTINATION(ST_GEOGPOINT(-3.70325,40.4167), NULL, 45, "miles") as destination2,
        \`@@BQ_PREFIX@@transformations.ST_DESTINATION(ST_GEOGPOINT(-3.70325,40.4167), 10, NULL, "miles") as destination3`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].destination1, null);
        assert.equal(rows[0].destination2, null);
        assert.equal(rows[0].destination3, null);
    });

    it ('ST_DESTINATION default values should work', async () => {
        const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_DESTINATION(ST_GEOGPOINT(-3.70325,40.4167), 10, 45, "kilometers") as defaultValue,
        \`@@BQ_PREFIX@@transformations.ST_DESTINATION(ST_GEOGPOINT(-3.70325,40.4167), 10, 45, NULL) as nullParam1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].nullParam1, rows[0].defaultValue);
    });
}); /* ST_DESTINATION integration tests */
