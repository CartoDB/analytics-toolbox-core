const { runQuery } = require('../../../../../common/snowflake/test-utils');

// Fixtures got from the turfjs tests
// Convert the points to a way snowflake can ingest them
const concaveHullFixturesIn = require('./concavehull_fixtures/in/concave-hull');
const concaveHullFixturesOut = require('./concavehull_fixtures/out/concave-hull');
const fijiFixturesIn = require('./concavehull_fixtures/in/fiji');
const fijiFixturesOut = require('./concavehull_fixtures/out/fiji');
const holeFixturesIn = require('./concavehull_fixtures/in/hole');
const holeFixturesOut = require('./concavehull_fixtures/out/hole');

function getFeatureArray (fixture) {
    let featuresArray = 'ARRAY_CONSTRUCT(';
    fixture.geom.features.forEach(function(item){
        featuresArray += 'ST_ASGEOJSON(TO_GEOGRAPHY(\'' + JSON.stringify(item.geometry) +'\'))::STRING,';
    });
    featuresArray = featuresArray.slice(0, -1) + ')';
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
    const query = `SELECT @@SF_PREFIX@@transformations.ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, ${getFeatureMaxEdge(concaveHullFixturesIn)}, ${getFeatureUnits(concaveHullFixturesIn)}) as concaveHull1,
    @@SF_PREFIX@@transformations.ST_CONCAVEHULL(${getFeatureArray(fijiFixturesIn)}, ${getFeatureMaxEdge(fijiFixturesIn)}, ${getFeatureUnits(fijiFixturesIn)}) as concaveHull2,
    @@SF_PREFIX@@transformations.ST_CONCAVEHULL(${getFeatureArray(holeFixturesIn)}, ${getFeatureMaxEdge(holeFixturesIn)}, ${getFeatureUnits(holeFixturesIn)}) as concaveHull3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].CONCAVEHULL1)).toEqual(concaveHullFixturesOut.value);
    expect(JSON.stringify(rows[0].CONCAVEHULL2)).toEqual(fijiFixturesOut.value);
    expect(JSON.stringify(rows[0].CONCAVEHULL3)).toEqual(holeFixturesOut.value);
});

test('ST_CONCAVEHULL should return NULL if any NULL mandatory argument', async () => {
    const query = 'SELECT @@SF_PREFIX@@transformations.ST_CONCAVEHULL(NULL, 10, \'kilometers\') as concaveHull1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].CONCAVEHULL1).toEqual(null);
});

test('ST_CONCAVEHULL default values should work', async () => {
    const query = `SELECT @@SF_PREFIX@@transformations.ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, CAST('inf' AS DOUBLE), 'kilometers') as defaultValue,
    @@SF_PREFIX@@transformations.ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, NULL, NULL) as nullParam1,
    @@SF_PREFIX@@transformations.ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}) as nullParam2,
    @@SF_PREFIX@@transformations.ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, CAST('inf' AS DOUBLE), NULL) as nullParam3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].NULLPARAM1).toEqual(rows[0].DEFAULTVALUE);
    expect(rows[0].NULLPARAM2).toEqual(rows[0].DEFAULTVALUE);
    expect(rows[0].NULLPARAM3).toEqual(rows[0].DEFAULTVALUE);
});