const { runQuery } = require('../../../common/test-utils');

test('ST_DESTINATION should work', async () => {
    const query = `SELECT \`@@BQ_DATASET@@.ST_DESTINATION\`(ST_GEOGPOINT(0, 0), 10, 90, "kilometers") as destination1,
    \`@@BQ_DATASET@@.ST_DESTINATION\`(ST_GEOGPOINT(-3.70325, 40.4167), 5, 45, "kilometers") as destination2,
    \`@@BQ_DATASET@@.ST_DESTINATION\`(ST_GEOGPOINT(-43.7625, -20), 150, -20, "miles") as destination3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].destination1.value).toEqual('POINT(0.0899320363724538 5.50674676307584e-18)');
    expect(rows[0].destination2.value).toEqual('POINT(-3.66146785439614 40.4484882583202)');
    expect(rows[0].destination3.value).toEqual('POINT(-44.5428812187219 -17.958278944262)');
});

test('ST_DESTINATION should return NULL if any NULL mandatory argument', async () => {
    const query = `SELECT \`@@BQ_DATASET@@.ST_DESTINATION\`(NULL, 10, 45, "miles") as destination1,
    \`@@BQ_DATASET@@.ST_DESTINATION\`(ST_GEOGPOINT(-3.70325,40.4167), NULL, 45, "miles") as destination2,
    \`@@BQ_DATASET@@.ST_DESTINATION\`(ST_GEOGPOINT(-3.70325,40.4167), 10, NULL, "miles") as destination3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].destination1).toEqual(null);
    expect(rows[0].destination2).toEqual(null);
    expect(rows[0].destination3).toEqual(null);
});

test('ST_DESTINATION default values should work', async () => {
    const query = `SELECT \`@@BQ_DATASET@@.ST_DESTINATION\`(ST_GEOGPOINT(-3.70325,40.4167), 10, 45, "kilometers") as defaultValue,
    \`@@BQ_DATASET@@.ST_DESTINATION\`(ST_GEOGPOINT(-3.70325,40.4167), 10, 45, NULL) as nullParam1`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].nullParam1).toEqual(rows[0].defaultValue);
});