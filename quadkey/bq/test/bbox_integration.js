const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('BBOX integration tests', () => {
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

    it ('BBOX should work', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.BBOX(162) as bbox1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.BBOX(12070922) as bbox2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.BBOX(791040491538) as bbox3,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.BBOX(12960460429066265) as bbox4`;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0]['bbox1'],[-90, 0, 0, 66.51326044311186]);
        assert.deepEqual(rows[0]['bbox2'],[-45, 44.840290651397986, -44.6484375, 45.08903556483103]);
        assert.deepEqual(rows[0]['bbox3'],[-45, 44.99976701918129, -44.998626708984375, 45.00073807829068]);
        assert.deepEqual(rows[0]['bbox4'],[-45, 44.999994612636684, -44.99998927116394, 45.00000219906962]);
    });

    it ('BBOX should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.BBOX(NULL);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });
}); /* QUADKEY integration tests */
