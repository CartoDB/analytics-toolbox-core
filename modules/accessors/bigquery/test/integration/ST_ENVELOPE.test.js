const { runQuery } = require('../../../../../common/bigquery/test-utils');

// Points and featureCollection got from the turfjs tests
// Convert the points to a way BigQuery can ingest them
const pointsFixturesIn = require('./envelope_fixtures/in/points');
const pointsFixturesOut = require('./envelope_fixtures/out/points');
const featureColFixturesIn = require('./envelope_fixtures/in/featureCollection');
const featureColFixturesOut = require('./envelope_fixtures/out/featureCollection');

function getFeatureArray(fixture) {
    let featuresArray = '[';
    fixture.geom.features.forEach(function(item){
        featuresArray += 'ST_GEOGFROMGEOJSON(\'' + JSON.stringify(item.geometry) +'\', make_valid => true),';
    });
    featuresArray = featuresArray.slice(0, -1) + ']';
    return featuresArray;
}

test('ST_ENVELOPE should work', async () => {
    const query = `
        SELECT
            \`@@BQ_PREFIX@@accessors.ST_ENVELOPE\`(${getFeatureArray(pointsFixturesIn)}) as envelope1,
            \`@@BQ_PREFIX@@accessors.ST_ENVELOPE\`(${getFeatureArray(featureColFixturesIn)}) as envelope2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].envelope1.value).toEqual(pointsFixturesOut.value);
    expect(rows[0].envelope2.value).toEqual(featureColFixturesOut.value);
});

test('ST_ENVELOPE should return NULL if any NULL mandatory argument', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@accessors.ST_ENVELOPE`(NULL) as envelope1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].envelope1).toEqual(null);
});