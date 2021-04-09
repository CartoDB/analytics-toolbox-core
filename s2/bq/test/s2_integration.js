const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_S2 = process.env.BQ_DATASET_S2;

describe('S2 integration tests', () => {

    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_S2) {
            throw "Missing BQ_DATASET_S2 env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('Returns the proper version', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.VERSION() as versioncol;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].versioncol, '1.2.10.0');
    });
}); /* S2 integration tests */
