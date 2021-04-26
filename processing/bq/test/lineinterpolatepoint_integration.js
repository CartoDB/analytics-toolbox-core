const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_PROCESSING = process.env.BQ_DATASET_PROCESSING;

describe('ST_LINE_INTERPOLATE_POINT integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_PROCESSING) {
            throw "Missing BQ_DATASET_PROCESSING env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('ST_LINE_INTERPOLATE_POINT should return NULL if any NULL mandatory argument', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROCESSING}\`.ST_LINE_INTERPOLATE_POINT(NULL, 250,'miles') as interpolation1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROCESSING}\`.ST_LINE_INTERPOLATE_POINT(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), NULL, 'miles') as interpolation2`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].interpolation1, null);
        assert.equal(rows[0].interpolation2, null);
    });

    it ('ST_LINE_INTERPOLATE_POINT default values should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROCESSING}\`.ST_LINE_INTERPOLATE_POINT(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), 250, 'kilometers') as defaultValue,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROCESSING}\`.ST_LINE_INTERPOLATE_POINT(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), 250, NULL) as nullParam1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].nullParam1, rows[0].defaultValue);
    });
}); /* ST_LINE_INTERPOLATE_POINT integration tests */
