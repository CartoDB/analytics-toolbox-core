const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_SKEL = process.env.BQ_DATASET_SKEL;

describe('SKEL integration tests', () => {

    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_SKEL) {
            throw "Missing BQ_DATASET_SKEL env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('Returns the proper version', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SKEL}\`.VERSION() as versioncol;`;

        const options = {
            query: query
        };

        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].versioncol, 1);
    });


    it ('Adds correctly', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SKEL}\`.EXAMPLE_ADD(5) as addition;`;

        const options = {
            query: query
        };

        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].addition, 6);
    });
}); /* SKEL integration tests */
