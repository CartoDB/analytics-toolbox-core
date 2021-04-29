const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_TRANSFORMATIONS = process.env.BQ_DATASET_TRANSFORMATIONS;

describe('ST_CENTERMEDIAN integration tests', () => {
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

    it ('ST_CENTERMEDIAN should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CENTERMEDIAN(ST_GEOGFROMTEXT("POLYGON ((4.77802276611328 45.7784187892391, 4.77338790893555 45.7402141789073, 4.82419967651367 45.713371483331, 4.89492416381836 45.7271539426975, 4.91037368774414 45.7608167797245, 4.88239288330078 45.792544274359, 4.82505798339844 45.7939805638674, 4.77802276611328 45.7784187892391))")) as centerMedian1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CENTERMEDIAN(ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))")) as centerMedian2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CENTERMEDIAN(ST_GEOGFROMTEXT("POLYGON ((-120 30, -90 40, 20 40, -45 -20, -120 30))")) as centerMedian3`;
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].centerMedian1.value, 'POINT(4.84119415283203 45.7580714303037)');
        assert.deepEqual(rows[0].centerMedian2.value, 'POINT(25.3783930513609 29.8376035441371)');
        assert.deepEqual(rows[0].centerMedian3.value, 'POINT(-47.9709554041732 29.6296190445491)');
    });

    it ('ST_CENTERMEDIAN should return NULL if any NULL mandatory argument', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CENTERMEDIAN(NULL) as centermedian1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].centermedian1, null);
    });
}); /* ST_CENTERMEDIAN integration tests */
