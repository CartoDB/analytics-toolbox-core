const { runQuery } = require('../../../../../common/snowflake/test-utils');

const pointFixturesIn = require('./buffer_fixtures/in/point');
const pointFixturesOut = require('./buffer_fixtures/out/point');

test('ST_BUFFER should work', async () => {
    const featureJSON = JSON.stringify(pointFixturesIn.geom.geometry);
    const query = `SELECT ST_ASTEXT(ST_BUFFER(TO_GEOGRAPHY('${featureJSON}'), 1000)) as buffer;`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].BUFFER).toEqual(pointFixturesOut.value_8);
});

test('ST_BUFFER should work with segments', async () => {
    const featureJSON = JSON.stringify(pointFixturesIn.geom.geometry);
    const query = `SELECT ST_ASTEXT(ST_BUFFER(TO_GEOGRAPHY('${featureJSON}'), 1000, 10)) as buffer;`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].BUFFER).toEqual(pointFixturesOut.value_10);
});