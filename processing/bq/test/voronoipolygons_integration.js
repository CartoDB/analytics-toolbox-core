const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');
const fixturesIn = require('./voronoi_fixtures/in');
const fixturesOut = require('./voronoi_fixtures/out');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_PROCESSING = process.env.BQ_DATASET_PROCESSING;

describe('PROCESSING integration tests', () => {
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

    // Points got from the turfjs tests
    // Convert the points to a way BigQuery can ingest them
    let pointsArray = '[';
    fixturesIn.points.features.forEach(function(item){
        pointsArray += 'ST_GEOGPOINT(' + item.geometry.coordinates[0] + ', ' + item.geometry.coordinates[1] + '),';
    });
    pointsArray = pointsArray.slice(0, -1) + ']';

    it('ST_VORONOIPOLYGONS should work', async () => {
        
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROCESSING}\`.ST_VORONOIPOLYGONS(${pointsArray}, [-76.0, 35.0, -70.0, 45.0]) as voronoi;`;
        
        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].voronoi.length, fixturesIn.points.features.length);
        assert.deepEqual(rows[0].voronoi.map(item => item.value), fixturesOut.expectedPoly1);
    });

    it('ST_VORONOIPOLYGONS should work with null bbox', async () => {

        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROCESSING}\`.ST_VORONOIPOLYGONS(${pointsArray}, null) as voronoi;`;
        
        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].voronoi.length, fixturesIn.points.features.length);
        assert.deepEqual(rows[0].voronoi.map(item => item.value), fixturesOut.expectedPoly2);
    });
    
    it('ST_VORONOIPOLYGONS should return an empty array if passed null geometry', async () => {

        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROCESSING}\`.ST_VORONOIPOLYGONS(null, null) as voronoi;`;
        
        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].voronoi, []);
    });

    it('ST_VORONOIPOLYGONS should fail if passed invalid bbox', async () => {

        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROCESSING}\`.ST_VORONOIPOLYGONS(${pointsArray}, [1.0, 0.5, 2.5]) as voronoi;`;
        
        let rows;
        await assert.rejects(async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });
}); /* PROCESSING integration tests */
