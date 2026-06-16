const { runQuery } = require('../../../common/test-utils');

// Points and featureCollection got from the turfjs tests
// Convert the points to a way BigQuery can ingest them
const pointsFixturesIn = require('./fixtures/st_envelope_points_in');
const pointsFixturesOut = require('./fixtures/st_envelope_points_out');
const featureColFixturesIn = require('./fixtures/st_envelope_featureCollection_in');
const featureColFixturesOut = require('./fixtures/st_envelope_featureCollection_out');

function getFeatureArray (fixture) {
    let featuresArray = '[';
    fixture.geom.features.forEach(function (item){
        featuresArray += 'ST_GEOGFROMGEOJSON(\'' + JSON.stringify(item.geometry) +'\', make_valid => true),';
    });
    featuresArray = featuresArray.slice(0, -1) + ']';
    return featuresArray;
}

test('ST_ENVELOPE should work', async () => {
    const query = `
        SELECT
            \`@@BQ_DATASET@@.ST_ENVELOPE\`(${getFeatureArray(pointsFixturesIn)}) as envelope1,
            \`@@BQ_DATASET@@.ST_ENVELOPE\`(${getFeatureArray(featureColFixturesIn)}) as envelope2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].envelope1.value).toEqual(pointsFixturesOut.value);
    expect(rows[0].envelope2.value).toEqual(featureColFixturesOut.value);
});

test('ST_ENVELOPE should return NULL if any NULL mandatory argument', async () => {
    const query = 'SELECT `@@BQ_DATASET@@.ST_ENVELOPE`(NULL) as envelope1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].envelope1).toEqual(null);
});

test('ST_ENVELOPE should return NULL for an array of only NULL geographies', async () => {
    // Regression test for sc-466893: ST_ENVELOPE([CAST(NULL AS GEOGRAPHY)])
    // used to fail with "ST_GeogFromGeoJSON failed: Longitude should be a number"
    const query =
        'SELECT `@@BQ_DATASET@@.ST_ENVELOPE`([CAST(NULL AS GEOGRAPHY)]) as envelope1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].envelope1).toEqual(null);
});

test('ST_ENVELOPE should ignore NULL elements in a mixed array', async () => {
    // A NULL element should be skipped, yielding the same envelope as the
    // array without NULLs (rather than failing or returning NULL).
    const query = `
        SELECT
            \`@@BQ_DATASET@@.ST_ENVELOPE\`([
                ST_GEOGPOINT(0, 0), CAST(NULL AS GEOGRAPHY), ST_GEOGPOINT(10, 10)
            ]) as envelopeMixed,
            \`@@BQ_DATASET@@.ST_ENVELOPE\`([
                ST_GEOGPOINT(0, 0), ST_GEOGPOINT(10, 10)
            ]) as envelopeClean`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].envelopeMixed).not.toEqual(null);
    expect(rows[0].envelopeMixed.value).toEqual(rows[0].envelopeClean.value);
});