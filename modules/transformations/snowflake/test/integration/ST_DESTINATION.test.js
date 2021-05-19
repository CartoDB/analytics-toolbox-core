const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('ST_DESTINATION should work', async () => {
    const query = `SELECT @@SF_PREFIX@@transformations.ST_DESTINATION(ST_POINT(0, 0), 10, 90, 'kilometers') as destination1,
    @@SF_PREFIX@@transformations.ST_DESTINATION(ST_POINT(-3.70325, 40.4167), 5, 45, 'kilometers') as destination2,
    @@SF_PREFIX@@transformations.ST_DESTINATION(ST_POINT(-43.7625, -20), 150, -20, 'miles') as destination3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].DESTINATION1)).toEqual('{"coordinates":[0.08993203637245381,5.506746763075836e-18],"type":"Point"}');
    expect(JSON.stringify(rows[0].DESTINATION2)).toEqual('{"coordinates":[-3.6614678543961365,40.44848825832016],"type":"Point"}');
    expect(JSON.stringify(rows[0].DESTINATION3)).toEqual('{"coordinates":[-44.54288121872185,-17.958278944262005],"type":"Point"}');
});

test('ST_DESTINATION should return NULL if any NULL mandatory argument', async () => {
    const query = `SELECT @@SF_PREFIX@@transformations.ST_DESTINATION(NULL, 10, 45, 'miles') as destination1,
    @@SF_PREFIX@@transformations.ST_DESTINATION(ST_POINT(-3.70325,40.4167), NULL, 45, 'miles') as destination2,
    @@SF_PREFIX@@transformations.ST_DESTINATION(ST_POINT(-3.70325,40.4167), 10, NULL, 'miles') as destination3,
    @@SF_PREFIX@@transformations.ST_DESTINATION(ST_POINT(-3.70325,40.4167), 10, 45, NULL) as destination4`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].DESTINATION1).toEqual(null);
    expect(rows[0].DESTINATION2).toEqual(null);
    expect(rows[0].DESTINATION3).toEqual(null);
    expect(rows[0].DESTINATION4).toEqual(null);
});

test('ST_DESTINATION default values should work', async () => {
    const query = `SELECT @@SF_PREFIX@@transformations.ST_DESTINATION(ST_POINT(-3.70325,40.4167), 10, 45, 'kilometers') as defaultValue,
    @@SF_PREFIX@@transformations.ST_DESTINATION(ST_POINT(-3.70325,40.4167), 10, 45) as nullParam1`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].NULLPARAM1).toEqual(rows[0].DEFAULTVALUE);
});