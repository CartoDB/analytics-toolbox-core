const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('KRING integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_QUADKEY) {
            throw "Missing BQ_DATASET_QUADKEY env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });
 
    it ('KRING should work', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(162) as kring1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(12070922) as kring2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(791040491538) as kring3,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(12960460429066265) as kring4`;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0]['kring1'],[130, 2, 258, 194, 66, 322, 34, 290, 162]);
        assert.deepEqual(rows[0]['kring2'],[12070890, 12038122, 12103658, 12070954, 12038186, 12103722, 12038154, 12103690, 12070922]);
        assert.deepEqual(rows[0]['kring3'],[791040491506, 791032102898, 791048880114, 791040491570, 791032102962, 791048880178, 791032102930, 791048880146, 791040491538]);
        assert.deepEqual(rows[0]['kring4'],[12960460429066232, 12960459355324408, 12960461502808056, 12960460429066296, 12960459355324472, 12960461502808120, 12960459355324440, 12960461502808088, 12960460429066264]);
    });

    it ('KRING should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(NULL);`;
        await assert.rejects( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
    });
}); /* QUADKEY integration tests */
