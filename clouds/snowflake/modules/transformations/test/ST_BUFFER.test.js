const { runQuery } = require('../../../common/test-utils');

const pointFixturesIn = require('./fixtures/st_buffer_in');
const pointFixturesOut = require('./fixtures/st_buffer_out');

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