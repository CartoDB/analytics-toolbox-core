const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_MEASUREMENTS = process.env.BQ_DATASET_MEASUREMENTS;

describe('ST_AZIMUTH integration tests', () => {
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

    it ('ST_AZIMUTH should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_AZIMUTH(ST_GEOGPOINT(0, 0), ST_GEOGPOINT(10, 0)) as azimuth1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_AZIMUTH(ST_GEOGPOINT(0, 0), ST_GEOGPOINT(10, 10)) as azimuth2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_AZIMUTH(ST_GEOGPOINT(0, 0), ST_GEOGPOINT(0, 10)) as azimuth3,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_AZIMUTH(ST_GEOGPOINT(0, 0), ST_GEOGPOINT(0, -10)) as azimuth4`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].azimuth1, 90);
        assert.equal(rows[0].azimuth2, 44.56145141325769);
        assert.equal(rows[0].azimuth3, 0);
        assert.equal(rows[0].azimuth4, 180);
    });

    it ('ST_AZIMUTH should return NULL if any NULL mandatory argument', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_AZIMUTH(NULL, ST_GEOGPOINT(-4.70325, 41.4167)) as azimuth1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_MEASUREMENTS}\`.ST_AZIMUTH(ST_GEOGPOINT(-3.70325, 40.4167), NULL) as azimuth2`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].azimuth1, null);
        assert.equal(rows[0].azimuth2, null);
    });
}); /* ST_AZIMUTH integration tests */
