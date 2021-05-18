const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_ANGLE should work', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@measurements.ST_ANGLE\`(ST_GEOGPOINT(10, 0), ST_GEOGPOINT(0, 0), ST_GEOGPOINT(0, 10), false) as angle1,
               \`@@BQ_PREFIX@@measurements.ST_ANGLE\`(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,40.4167), ST_GEOGPOINT(-5.70325 ,40.4167), false) as angle2,
               \`@@BQ_PREFIX@@measurements.ST_ANGLE\`(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,40.4167), ST_GEOGPOINT(-5.70325 ,40.4167), true) as angle3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].angle1).toEqual(90);
    expect(rows[0].angle2).toEqual(180.64835137913326);
    expect(rows[0].angle3).toEqual(180);
});

test('ST_ANGLE should return NULL if any NULL mandatory argument', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@measurements.ST_ANGLE\`(NULL, ST_GEOGPOINT(-4.70325 ,10.4167), ST_GEOGPOINT(-5.70325 ,40.4167), false) as angle1,
               \`@@BQ_PREFIX@@measurements.ST_ANGLE\`(ST_GEOGPOINT(-3.70325 ,40.4167), NULL, ST_GEOGPOINT(-5.70325 ,40.4167), false) as angle2,
               \`@@BQ_PREFIX@@measurements.ST_ANGLE\`(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,10.4167), NULL, false) as angle3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].angle1).toEqual(null);
    expect(rows[0].angle2).toEqual(null);
    expect(rows[0].angle3).toEqual(null);
});

test('ST_ANGLE default values should work', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@measurements.ST_ANGLE\`(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,10.4167), ST_GEOGPOINT(-5.70325 ,40.4167), false) as defaultValue,
               \`@@BQ_PREFIX@@measurements.ST_ANGLE\`(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,10.4167), ST_GEOGPOINT(-5.70325 ,40.4167), NULL) as nullParam
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].nullParam).toEqual(rows[0].defaultValue);
});