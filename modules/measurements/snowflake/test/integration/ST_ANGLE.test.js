const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('ST_ANGLE should work', async () => {
    const query = `
        SELECT ST_ANGLE(ST_POINT(10, 0), ST_POINT(0, 0), ST_POINT(0, 10)) as angle1,
               ST_ANGLE(ST_POINT(-3.70325 ,40.4167), ST_POINT(-4.70325 ,40.4167), ST_POINT(-5.70325 ,40.4167)) as angle2
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].ANGLE1).toEqual(90);
    expect(rows[0].ANGLE2).toEqual(180.648351379);
});

test('ST_ANGLE should return NULL if any NULL mandatory argument', async () => {
    const query = `
        SELECT ST_ANGLE(NULL, ST_POINT(-4.70325 ,10.4167), ST_POINT(-5.70325 ,40.4167)) as angle1,
               ST_ANGLE(ST_POINT(-3.70325 ,40.4167), NULL, ST_POINT(-5.70325 ,40.4167)) as angle2,
               ST_ANGLE(ST_POINT(-3.70325 ,40.4167), ST_POINT(-4.70325 ,10.4167), NULL) as angle3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].ANGLE1).toEqual(null);
    expect(rows[0].ANGLE2).toEqual(null);
    expect(rows[0].ANGLE3).toEqual(null);
});