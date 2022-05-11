const { runQuery } = require('../../../../../common/bigquery/test-utils');

// Fixtures got from the turfjs tests
// Convert the points to a way BigQuery can ingest them
const concaveHullFixturesIn = require('./concavehull_fixtures/in/concave-hull');
const concaveHullFixturesOut = require('./concavehull_fixtures/out/concave-hull');
const fijiFixturesIn = require('./concavehull_fixtures/in/fiji');
const fijiFixturesOut = require('./concavehull_fixtures/out/fiji');
const holeFixturesIn = require('./concavehull_fixtures/in/hole');
const holeFixturesOut = require('./concavehull_fixtures/out/hole');
const pointFixturesIn = require('./concavehull_fixtures/in/point');
const pointFixturesOut = require('./concavehull_fixtures/out/point');
const duplicatesFixturesIn = require('./concavehull_fixtures/in/duplicates');
const duplicatesFixturesOut = require('./concavehull_fixtures/out/duplicates');

function getFeatureArray (fixture) {
    let featuresArray = '[';
    fixture.geom.features.forEach(function (item){
        featuresArray += 'ST_GEOGFROMGEOJSON(\'' + JSON.stringify(item.geometry) +'\', make_valid => true),';
    });
    featuresArray = featuresArray.slice(0, -1) + ']';
    return featuresArray;
}

function getFeatureMaxEdge (fixture) {
    if (fixture.geom.properties != null && fixture.geom.properties.maxEdge) {  
        return fixture.geom.properties.maxEdge;
    }
    return null;
}

function getFeatureUnits (fixture) {
    if (fixture.geom.properties != null && fixture.geom.properties.units) {  
        return '\'' + fixture.geom.properties.units + '\'';
    }
    return null;
}

test('ST_CONCAVEHULL should work', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@carto.ST_CONCAVEHULL\`(${getFeatureArray(concaveHullFixturesIn)}, ${getFeatureMaxEdge(concaveHullFixturesIn)}, ${getFeatureUnits(concaveHullFixturesIn)}) as concaveHull1,
    \`@@BQ_PREFIX@@carto.ST_CONCAVEHULL\`(${getFeatureArray(fijiFixturesIn)}, ${getFeatureMaxEdge(fijiFixturesIn)}, ${getFeatureUnits(fijiFixturesIn)}) as concaveHull2,
    \`@@BQ_PREFIX@@carto.ST_CONCAVEHULL\`(${getFeatureArray(holeFixturesIn)}, ${getFeatureMaxEdge(holeFixturesIn)}, ${getFeatureUnits(holeFixturesIn)}) as concaveHull3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].concaveHull1.value).toEqual(concaveHullFixturesOut.value);
    expect(rows[0].concaveHull2.value).toEqual(fijiFixturesOut.value);
    expect(rows[0].concaveHull3.value).toEqual(holeFixturesOut.value);
});

test('ST_CONCAVEHULL should return NULL if any NULL mandatory argument', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.ST_CONCAVEHULL`(NULL, 10, \'kilometers\') as concaveHull1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].concaveHull1).toEqual(null);
});

test('ST_CONCAVEHULL default values should work', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@carto.ST_CONCAVEHULL\`(${getFeatureArray(concaveHullFixturesIn)}, CAST('Infinity' AS FLOAT64), "kilometers") as defaultValue,
    \`@@BQ_PREFIX@@carto.ST_CONCAVEHULL\`(${getFeatureArray(concaveHullFixturesIn)}, NULL, NULL) as nullParam1`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].nullParam1).toEqual(rows[0].defaultValue);
});

test('ST_CONCAVEHULL with a single point and line should work', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@carto.ST_CONCAVEHULL\`(${getFeatureArray(duplicatesFixturesIn)}, CAST('Infinity' AS FLOAT64), "kilometers") as line,
    \`@@BQ_PREFIX@@carto.ST_CONCAVEHULL\`(${getFeatureArray(pointFixturesIn)}, NULL, NULL) as point`;
    const rows = await runQuery(query);

    expect(rows.length).toEqual(1);
    expect(rows[0].line.value).toEqual(duplicatesFixturesOut.value);
    expect(rows[0].point.value).toEqual(pointFixturesOut.value);
});