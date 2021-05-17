const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('ST_ANGLE should work', async () => {
    const query = `
        SELECT @@SF_PREFIX@@measurements.ST_ANGLE(ST_POINT(10, 0), ST_POINT(0, 0), ST_POINT(0, 10), false) as angle1,
               @@SF_PREFIX@@measurements.ST_ANGLE(ST_POINT(-3.70325 ,40.4167), ST_POINT(-4.70325 ,40.4167), ST_POINT(-5.70325 ,40.4167), false) as angle2,
               @@SF_PREFIX@@measurements.ST_ANGLE(ST_POINT(-3.70325 ,40.4167), ST_POINT(-4.70325 ,40.4167), ST_POINT(-5.70325 ,40.4167), true) as angle3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].ANGLE1).toEqual(90);
    expect(rows[0].ANGLE2).toEqual(180.648351379);
    expect(rows[0].ANGLE3).toEqual(180);
});

test('ST_ANGLE should return NULL if any NULL mandatory argument', async () => {
    const query = `
        SELECT @@SF_PREFIX@@measurements.ST_ANGLE(NULL, ST_POINT(-4.70325 ,10.4167), ST_POINT(-5.70325 ,40.4167), false) as angle1,
               @@SF_PREFIX@@measurements.ST_ANGLE(ST_POINT(-3.70325 ,40.4167), NULL, ST_POINT(-5.70325 ,40.4167), false) as angle2,
               @@SF_PREFIX@@measurements.ST_ANGLE(ST_POINT(-3.70325 ,40.4167), ST_POINT(-4.70325 ,10.4167), NULL, false) as angle3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].ANGLE1).toEqual(null);
    expect(rows[0].ANGLE2).toEqual(null);
    expect(rows[0].ANGLE3).toEqual(null);
});

test('ST_ANGLE default values should work', async () => {
    const query = `
        SELECT @@SF_PREFIX@@measurements.ST_ANGLE(ST_POINT(-3.70325 ,40.4167), ST_POINT(-4.70325 ,10.4167), ST_POINT(-5.70325 ,40.4167), false) as defaultValue,
               @@SF_PREFIX@@measurements.ST_ANGLE(ST_POINT(-3.70325 ,40.4167), ST_POINT(-4.70325 ,10.4167), ST_POINT(-5.70325 ,40.4167), NULL) as nullParam1,
               @@SF_PREFIX@@measurements.ST_ANGLE(ST_POINT(-3.70325 ,40.4167), ST_POINT(-4.70325 ,10.4167), ST_POINT(-5.70325 ,40.4167)) as nullParam2
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].NULLPARAM1).toEqual(rows[0].DEFAULTVALUE);
    expect(rows[0].NULLPARAM2).toEqual(rows[0].DEFAULTVALUE);
});