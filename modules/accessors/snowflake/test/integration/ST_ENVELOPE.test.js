const { runQuery } = require('../../../../../common/snowflake/test-utils');

// Points and featureCollection got from the turfjs tests
// Convert the points to a way BigQuery can ingest them
const pointsFixturesIn = require('./envelope_fixtures/in/points');
const pointsFixturesOut = require('./envelope_fixtures/out/points');
const featureColFixturesIn = require('./envelope_fixtures/in/featureCollection');
const featureColFixturesOut = require('./envelope_fixtures/out/featureCollection');

function getFeatureArray (fixture) {
    let featuresArray = 'ARRAY_CONSTRUCT(';
    fixture.geom.features.forEach(function (item){
        featuresArray += 'ST_ASGEOJSON(TO_GEOGRAPHY(\'' + JSON.stringify(item.geometry) +'\'))::STRING,';
    });
    featuresArray = featuresArray.slice(0, -1) + ')';
    return featuresArray;
}

test('ST_ENVELOPE should work', async () => {
    const query = `
        SELECT
            ST_ENVELOPE(${getFeatureArray(pointsFixturesIn)}) as envelope1,
            ST_ENVELOPE(${getFeatureArray(featureColFixturesIn)}) as envelope2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    console.log(getFeatureArray(featureColFixturesIn));
    expect(JSON.stringify(rows[0].ENVELOPE1)).toEqual(pointsFixturesOut.value);
    expect(JSON.stringify(rows[0].ENVELOPE2)).toEqual(featureColFixturesOut.value);
});

test('ST_ENVELOPE should return NULL if any NULL mandatory argument', async () => {
    const query = 'SELECT ST_ENVELOPE(NULL) as envelope1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].ENVELOPE1).toEqual(null);
});