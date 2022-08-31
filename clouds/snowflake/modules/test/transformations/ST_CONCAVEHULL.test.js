const { runQuery } = require('../../../common/test-utils');

// Fixtures got from the turfjs tests
// Convert the points to a way snowflake can ingest them
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
    let featuresArray = 'ARRAY_CONSTRUCT(';
    fixture.geom.features.forEach(function (item){
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
    const query = `SELECT ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, ${getFeatureMaxEdge(concaveHullFixturesIn)}, ${getFeatureUnits(concaveHullFixturesIn)}) as concaveHull1,
    ST_CONCAVEHULL(${getFeatureArray(fijiFixturesIn)}, ${getFeatureMaxEdge(fijiFixturesIn)}, ${getFeatureUnits(fijiFixturesIn)}) as concaveHull2,
    ST_CONCAVEHULL(${getFeatureArray(holeFixturesIn)}, ${getFeatureMaxEdge(holeFixturesIn)}, ${getFeatureUnits(holeFixturesIn)}) as concaveHull3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].CONCAVEHULL1)).toEqual(concaveHullFixturesOut.value);
    expect(JSON.stringify(rows[0].CONCAVEHULL2)).toEqual(fijiFixturesOut.value);
    expect(JSON.stringify(rows[0].CONCAVEHULL3)).toEqual(holeFixturesOut.value);
});

test('ST_CONCAVEHULL should return NULL if any NULL mandatory argument', async () => {
    const query = `SELECT ST_CONCAVEHULL(NULL, 10, 'kilometers') as concaveHull1,
        ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, NULL, 'kilometers') as concaveHull2,
        ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, 10, NULL) as concaveHull3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].CONCAVEHULL1).toEqual(null);
    expect(rows[0].CONCAVEHULL2).toEqual(null);
    expect(rows[0].CONCAVEHULL3).toEqual(null);
});

test('ST_CONCAVEHULL default values should work', async () => {
    const query = `SELECT ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, CAST('inf' AS DOUBLE), 'kilometers') as defaultValue,
    ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}) as nullParam1,
    ST_CONCAVEHULL(${getFeatureArray(concaveHullFixturesIn)}, CAST('inf' AS DOUBLE)) as nullParam2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].NULLPARAM1).toEqual(rows[0].DEFAULTVALUE);
    expect(rows[0].NULLPARAM2).toEqual(rows[0].DEFAULTVALUE);
});

test('ST_CONCAVEHULL with a single point and line should work', async () => {
    const query = `SELECT ST_CONCAVEHULL(${getFeatureArray(duplicatesFixturesIn)}) as line,
    ST_CONCAVEHULL(${getFeatureArray(pointFixturesIn)}) as point`;
    const rows = await runQuery(query);

    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].LINE)).toEqual(duplicatesFixturesOut.value);
    expect(JSON.stringify(rows[0].POINT)).toEqual(pointFixturesOut.value);
});