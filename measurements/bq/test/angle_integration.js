const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_MEASUREMENTS = process.env.BQ_DATASET_MEASUREMENTS;

describe('ST_ANGLE integration tests', () => {
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

    it ('ST_ANGLE should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_ANGLE(ST_GEOGPOINT(10, 0), ST_GEOGPOINT(0, 0), ST_GEOGPOINT(0, 10), false) as angle1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_ANGLE(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,40.4167), ST_GEOGPOINT(-5.70325 ,40.4167), false) as angle2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_ANGLE(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,40.4167), ST_GEOGPOINT(-5.70325 ,40.4167), true) as angle3`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].angle1, 90);
        assert.equal(rows[0].angle2, 180.64835137913326);
        assert.equal(rows[0].angle3, 180);
    });

    it ('ST_ANGLE should return NULL if any NULL mandatory argument', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_ANGLE(NULL, ST_GEOGPOINT(-4.70325 ,10.4167), ST_GEOGPOINT(-5.70325 ,40.4167), false) as angle1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_ANGLE(ST_GEOGPOINT(-3.70325 ,40.4167), NULL, ST_GEOGPOINT(-5.70325 ,40.4167), false) as angle2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_ANGLE(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,10.4167), NULL, false) as angle3`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].angle1, null);
        assert.equal(rows[0].angle2, null);
        assert.equal(rows[0].angle3, null);
    });

    it ('ST_ANGLE default values should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_ANGLE(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,10.4167), ST_GEOGPOINT(-5.70325 ,40.4167), false) as defaultValue,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_ANGLE(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,10.4167), ST_GEOGPOINT(-5.70325 ,40.4167), NULL) as nullParam1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].nullParam1, rows[0].defaultValue);
    });
}); /* ST_ANGLE integration tests */
