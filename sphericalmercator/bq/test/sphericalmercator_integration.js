const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_SPHERICALMERCATOR = process.env.BQ_DATASET_SPHERICALMERCATOR;

describe('SPHERICALMERCATOR integration tests', () => {

    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_SPHERICALMERCATOR) {
            throw "Missing BQ_DATASET_SPHERICALMERCATOR env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('Returns the proper version', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SPHERICALMERCATOR}\`.VERSION() as versioncol;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].versioncol, 1);
    });

    it ('BBOX returns the proper value', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SPHERICALMERCATOR}\`.BBOX(0, 0, 0, 256) as bbox;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].bbox, [-180, -85.05112877980659, 180, 85.0511287798066])

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SPHERICALMERCATOR}\`.BBOX(0, 0, 1, 256) as bbox;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].bbox, [-180, 0, 0, 85.0511287798066]);
    });

    it ('XYZ returns the proper value', async () => {
        let bbox = [-180, -85.05112877980659, 180, 85.0511287798066];
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SPHERICALMERCATOR}\`.XYZ([${bbox}], 0, 256) as xyz;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query});
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].xyz, { minX: 0, minY: 0, maxX: 0, maxY: 0 })

        bbox = [-180, 0, 0, 85.0511287798066];
        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SPHERICALMERCATOR}\`.XYZ([${bbox}], 1, 256) as xyz;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query});
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].xyz, { minX: 0, minY: 0, maxX: 0, maxY: 0 });
    });
}); /* SPHERICALMERCATOR integration tests */
