const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_PLACEKEY = process.env.BQ_DATASET_PLACEKEY;

describe('PLACEKEY integration tests', () => {

    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_PLACEKEY) {
            throw "Missing BQ_DATASET_PLACEKEY env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('Returns the proper version', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PLACEKEY}\`.VERSION() as versioncol;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].versioncol, 1);
    });

    it ('Placekey / H3 conversions should work', async () => {
        let latitude = 10;
        let longitude = -20;

        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PLACEKEY}\`.LONGLAT_ASPLACEKEY(${longitude}, ${latitude}) as placekey;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        const placekey = rows[0].placekey;
        
        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PLACEKEY}\`.PLACEKEY_FROMH3(
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PLACEKEY}\`.H3_FROMPLACEKEY('${placekey}')) as placekey;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(placekey, rows[0].placekey);
    });

}); /* PLACEKEY integration tests */
