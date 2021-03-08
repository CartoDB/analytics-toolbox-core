const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_S2 = process.env.BQ_DATASET_S2;

describe('ST_GEOGFROMID_BOUNDARY integration tests', () => {

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

    it('ST_GEOGFROMID_BOUNDARY functions should work', async() => {
        const level = 18;
        const latitude = -14;
        const longitude = 125;
        const bounds = 'POLYGON((125.000260404646 -13.999959549589, 125.000260404646 -13.9996486905691, 124.999916074945 -13.9997052848802, 124.999916074945 -14.0000161450551, 125.000260404646 -13.999959549589))';

        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ST_GEOGFROMID_BOUNDARY(
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.LONGLAT_ASID(${longitude},${latitude},${level})) as boundary;`;
        
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(bounds, rows[0].boundary.value);
    });

    it ('ST_GEOGFROMID_BOUNDARY should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ST_GEOGFROMID_BOUNDARY(NULL);`;
        await assert.rejects( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
    });
}); /* S2 integration tests */
