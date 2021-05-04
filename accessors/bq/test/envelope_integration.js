const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_ACCESSORS = process.env.BQ_DATASET_ACCESSORS;

// Points and featureCollection got from the turfjs tests
// Convert the points to a way BigQuery can ingest them
const pointsFixturesIn = require('./envelope_fixtures/in/points');
const pointsFixturesOut = require('./envelope_fixtures/out/points');
const featureColFixturesIn = require('./envelope_fixtures/in/featureCollection');
const featureColFixturesOut = require('./envelope_fixtures/out/featureCollection');

function getFeatureArray(fixture)
{
    let featuresArray = '[';
    fixture.geom.features.forEach(function(item){
        featuresArray += "ST_GEOGFROMGEOJSON('" + JSON.stringify(item.geometry) +"', make_valid => true),";
    });
    featuresArray = featuresArray.slice(0, -1) + ']';
    return featuresArray;
}

describe('ST_ENVELOPE integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_ACCESSORS) {
            throw "Missing BQ_DATASET_ACCESSORS env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('ST_ENVELOPE should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_ACCESSORS}\`.ST_ENVELOPE(${getFeatureArray(pointsFixturesIn)}) as envelope1,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_ACCESSORS}\`.ST_ENVELOPE(${getFeatureArray(featureColFixturesIn)}) as envelope2`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].envelope1.value, pointsFixturesOut.value);
        assert.deepEqual(rows[0].envelope2.value, featureColFixturesOut.value);
    });

    it ('ST_ENVELOPE should return NULL if any NULL mandatory argument', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_ACCESSORS}\`.ST_ENVELOPE(NULL) as envelope1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].envelope1, null);
    });
}); /* ST_ENVELOPE integration tests */
