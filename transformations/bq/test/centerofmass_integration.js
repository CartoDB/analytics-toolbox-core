const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_TRANSFORMATIONS = process.env.BQ_DATASET_TRANSFORMATIONS;

describe('ST_CENTEROFMASS integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_TRANSFORMATIONS) {
            throw "Missing BQ_DATASET_TRANSFORMATIONS env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('ST_CENTEROFMASS should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CENTEROFMASS(ST_GEOGFROMTEXT("POLYGON ((4.77802276611328 45.7784187892391, 4.77338790893555 45.7402141789073, 4.82419967651367 45.713371483331, 4.89492416381836 45.7271539426975, 4.91037368774414 45.7608167797245, 4.88239288330078 45.792544274359, 4.82505798339844 45.7939805638674, 4.77802276611328 45.7784187892391))")) as centerOfMass1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CENTEROFMASS(ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))")) as centerOfMass2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CENTEROFMASS(ST_GEOGFROMTEXT("POLYGON ((-120 30, -90 40, 20 40, -45 -20, -120 30))")) as centerOfMass3`;
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].centerOfMass1.value, 'POINT(4.8407289651371 45.7558120999642)');
        assert.deepEqual(rows[0].centerOfMass2.value, 'POINT(25.1730977433239 27.2789529273059)');
        assert.deepEqual(rows[0].centerOfMass3.value, 'POINT(-47.8556239494899 25.6704051126407)');
    });

    it ('ST_CENTEROFMASS should return NULL if any NULL mandatory argument', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CENTEROFMASS(NULL) as centerofmass1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].centerofmass1, null);
    });
}); /* ST_CENTEROFMASS integration tests */
