const { runQuery } = require('../../../common/test-utils');

// Fixtures got from the turfjs tests
// Convert the points to a way BigQuery can ingest them
const concaveHullFixturesIn = require('./fixtures/st_concavehull_in');
const concaveHullFixturesOut = require('./fixtures/st_concavehull_out');
const fijiFixturesIn = require('./fixtures/st_concavehull_fiji_in');
const fijiFixturesOut = require('./fixtures/st_concavehull_fiji_out');
const holeFixturesIn = require('./fixtures/st_concavehull_hole_in');
const holeFixturesOut = require('./fixtures/st_concavehull_hole_out');
const pointFixturesIn = require('./fixtures/st_concavehull_point_in');
const pointFixturesOut = require('./fixtures/st_concavehull_point_out');
const duplicatesFixturesIn = require('./fixtures/st_concavehull_duplicates_in');
const duplicatesFixturesOut = require('./fixtures/st_concavehull_duplicates_out');

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
    const query = `SELECT \`@@BQ_DATASET@@.ST_CONCAVEHULL\`(${getFeatureArray(concaveHullFixturesIn)}, ${getFeatureMaxEdge(concaveHullFixturesIn)}, ${getFeatureUnits(concaveHullFixturesIn)}) as concaveHull1,
    \`@@BQ_DATASET@@.ST_CONCAVEHULL\`(${getFeatureArray(fijiFixturesIn)}, ${getFeatureMaxEdge(fijiFixturesIn)}, ${getFeatureUnits(fijiFixturesIn)}) as concaveHull2,
    \`@@BQ_DATASET@@.ST_CONCAVEHULL\`(${getFeatureArray(holeFixturesIn)}, ${getFeatureMaxEdge(holeFixturesIn)}, ${getFeatureUnits(holeFixturesIn)}) as concaveHull3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].concaveHull1.value).toEqual(concaveHullFixturesOut.value);
    expect(rows[0].concaveHull2.value).toEqual(fijiFixturesOut.value);
    expect(rows[0].concaveHull3.value).toEqual(holeFixturesOut.value);
});

test('ST_CONCAVEHULL should return NULL if any NULL mandatory argument', async () => {
    const query = 'SELECT `@@BQ_DATASET@@.ST_CONCAVEHULL`(NULL, 10, \'kilometers\') as concaveHull1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].concaveHull1).toEqual(null);
});

test('ST_CONCAVEHULL default values should work', async () => {
    const query = `SELECT \`@@BQ_DATASET@@.ST_CONCAVEHULL\`(${getFeatureArray(concaveHullFixturesIn)}, CAST('Infinity' AS FLOAT64), "kilometers") as defaultValue,
    \`@@BQ_DATASET@@.ST_CONCAVEHULL\`(${getFeatureArray(concaveHullFixturesIn)}, NULL, NULL) as nullParam1`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].nullParam1).toEqual(rows[0].defaultValue);
});

test('ST_CONCAVEHULL with a single point and line should work', async () => {
    const query = `SELECT \`@@BQ_DATASET@@.ST_CONCAVEHULL\`(${getFeatureArray(duplicatesFixturesIn)}, CAST('Infinity' AS FLOAT64), "kilometers") as line,
    \`@@BQ_DATASET@@.ST_CONCAVEHULL\`(${getFeatureArray(pointFixturesIn)}, NULL, NULL) as point`;
    const rows = await runQuery(query);

    expect(rows.length).toEqual(1);
    expect(rows[0].line.value).toEqual(duplicatesFixturesOut.value);
    expect(rows[0].point.value).toEqual(pointFixturesOut.value);
});