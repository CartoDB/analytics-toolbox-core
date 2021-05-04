const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');
const fixturesIn = require('./delaunay_fixtures/in');
const fixturesOut = require('./delaunay_fixtures/out');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_PROCESSING = process.env.BQ_DATASET_PROCESSING;

describe('DELAUNAY POLYGONS integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_PROCESSING) {
            throw "Missing BQ_DATASET_PROCESSING env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it('ST_DELAUNAYPOLYGONS should work', async () => {
        
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROCESSING}\`.ST_DELAUNAYPOLYGONS(${fixturesIn.input2}) as delaunay;`;
        
        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].delaunay.length, fixturesOut.expectedTriangles2.length);
        assert.deepEqual(rows[0].delaunay.map(item => item.value), fixturesOut.expectedTriangles2);
    });

    it('ST_DELAUNAYPOLYGONS should return an empty array if passed null geometry', async () => {

        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROCESSING}\`.ST_DELAUNAYPOLYGONS(null) as delaunay;`;
        
        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].delaunay, []);
    });
}); /* PROCESSING integration tests */
