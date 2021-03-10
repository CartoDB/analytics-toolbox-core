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
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(162,1) as kring1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(12070922,1) as kring2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(791040491538,1) as kring3,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(12960460429066265,1) as kring4,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(12070922,2) as kring5,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(791040491538,3) as kring6,`;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].kring1,[34, 2, 130, 258, 290, 322, 194, 66, 162]);
        assert.deepEqual(rows[0].kring2,[12038154, 12038122, 12070890, 12103658, 12103690, 12103722, 12070954, 12038186, 12070922]);
        assert.deepEqual(rows[0].kring3,[791032102930, 791032102898, 791040491506, 791048880114, 791048880146, 791048880178, 791040491570, 791032102962, 791040491538]);
        assert.deepEqual(rows[0].kring4,[12960459355324440, 12960459355324408, 12960460429066232, 12960461502808056, 12960461502808088, 12960461502808120, 12960460429066296, 12960459355324472, 12960460429066264]);
        assert.deepEqual(rows[0].kring5,[12038154, 12038122, 12070890, 12103658, 12103690, 12103722, 12070954, 12038186, 12038154, 12038122, 12070890, 12103658, 12103690, 12103722, 12070954, 12038186, 12038154, 12038122, 12070890, 12103658, 12103690, 12103722, 12070954, 12038186, 12070922]);
        assert.deepEqual(rows[0].kring6,[791032102930, 791032102898, 791040491506, 791048880114, 791048880146, 791048880178, 791040491570, 791032102962, 791032102930, 791032102898, 791040491506, 791048880114, 791048880146, 791048880178, 791040491570, 791032102962, 791032102930, 791032102898, 791040491506, 791048880114, 791048880146, 791048880178, 791040491570, 791032102962, 791032102930, 791032102898, 791040491506, 791048880114, 791048880146, 791048880178, 791040491570, 791032102962, 791032102930, 791032102898, 791040491506, 791048880114, 791048880146, 791048880178, 791040491570, 791032102962, 791032102930, 791032102898, 791040491506, 791048880114, 791048880146, 791048880178, 791040491570, 791032102962, 791040491538]);
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
