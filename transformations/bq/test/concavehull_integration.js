const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_TRANSFORMATIONS = process.env.BQ_DATASET_TRANSFORMATIONS;

// Fixtures got from the turfjs tests
// Convert the points to a way BigQuery can ingest them
const concaveHullFixturesIn = require('./concavehull_fixtures/in/concave-hull');
const concaveHullFixturesOut = require('./concavehull_fixtures/out/concave-hull');
const fijiFixturesIn = require('./concavehull_fixtures/in/fiji');
const fijiFixturesOut = require('./concavehull_fixtures/out/fiji');
const holeFixturesIn = require('./concavehull_fixtures/in/hole');
const holeFixturesOut = require('./concavehull_fixtures/out/hole');

function getFeatureArray(fixture)
{
    let featuresArray = '[';
    fixture.geom.features.forEach(function(item){
        featuresArray += "ST_GEOGFROMGEOJSON('" + JSON.stringify(item.geometry) +"', make_valid => true),";
    });
    featuresArray = featuresArray.slice(0, -1) + ']';
    return featuresArray;
}

function getFeatureMaxEdge(fixture)
{
    if(fixture.geom.properties != null && fixture.geom.properties.maxEdge)
    {  
        return fixture.geom.properties.maxEdge;
    }
    return null;
}

function getFeatureUnits(fixture)
{
    if(fixture.geom.properties != null && fixture.geom.properties.units)
    {  
        return "'" + fixture.geom.properties.units + "'";
    }
    return null;
}

describe('ST_CONCAVEHULL integration tests', () => {
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

    it ('ST_CONCAVEHULL should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, ${getFeatureMaxEdge(concaveHullFixturesIn)}, ${getFeatureUnits(concaveHullFixturesIn)}) as concaveHull1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CONCAVEHULL(${getFeatureArray(fijiFixturesIn)}, ${getFeatureMaxEdge(fijiFixturesIn)}, ${getFeatureUnits(fijiFixturesIn)}) as concaveHull2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CONCAVEHULL(${getFeatureArray(holeFixturesIn)}, ${getFeatureMaxEdge(holeFixturesIn)}, ${getFeatureUnits(holeFixturesIn)}) as concaveHull3`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].concaveHull1.value, concaveHullFixturesOut.value);
        assert.equal(rows[0].concaveHull2.value, fijiFixturesOut.value);
        assert.equal(rows[0].concaveHull3.value, holeFixturesOut.value);
    });

    it ('ST_CONCAVEHULL should return NULL if any NULL mandatory argument', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CONCAVEHULL(NULL, 10, 'kilometers') as concaveHull1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].concaveHull1, null);
    });

    it ('ST_CONCAVEHULL default values should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, CAST('Infinity' AS FLOAT64), "kilometers") as defaultValue,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, NULL, NULL) as nullParam1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].nullParam1, rows[0].defaultValue);
    });
}); /* ST_CONCAVEHULL integration tests */
