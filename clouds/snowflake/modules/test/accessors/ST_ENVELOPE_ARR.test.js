const { runQuery } = require('../../../common/test-utils');

// Points and featureCollection got from the turfjs tests
// Convert the points to a way BigQuery can ingest them
const pointsFixturesIn = require('./fixtures/st_envelope_arr_points_in');
const pointsFixturesOut = require('./fixtures/st_envelope_arr_points_out');
const featureColFixturesIn = require('./fixtures/st_envelope_arr_featureCollection_in');
const featureColFixturesOut = require('./fixtures/st_envelope_arr_featureCollection_out');

function getFeatureArray (fixture) {
    let featuresArray = 'ARRAY_CONSTRUCT(';
    fixture.geom.features.forEach(function (item){
        featuresArray += 'ST_ASGEOJSON(TO_GEOGRAPHY(\'' + JSON.stringify(item.geometry) +'\'))::STRING,';
    });
    featuresArray = featuresArray.slice(0, -1) + ')';
    return featuresArray;
}

test('ST_ENVELOPE_ARR should work', async () => {
    const query = `
        SELECT
            ST_ENVELOPE_ARR(${getFeatureArray(pointsFixturesIn)}) as envelope1,
            ST_ENVELOPE_ARR(${getFeatureArray(featureColFixturesIn)}) as envelope2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].ENVELOPE1)).toEqual(pointsFixturesOut.value);
    expect(JSON.stringify(rows[0].ENVELOPE2)).toEqual(featureColFixturesOut.value);
});

test('ST_ENVELOPE_ARR should return NULL if any NULL mandatory argument', async () => {
    const query = 'SELECT ST_ENVELOPE_ARR(NULL) as envelope1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].ENVELOPE1).toEqual(null);
});