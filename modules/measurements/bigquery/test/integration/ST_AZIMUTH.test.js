const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_AZIMUTH should work', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@measurements.ST_AZIMUTH\`(ST_GEOGPOINT(0, 0), ST_GEOGPOINT(10, 0)) as azimuth1,
               \`@@BQ_PREFIX@@measurements.ST_AZIMUTH\`(ST_GEOGPOINT(0, 0), ST_GEOGPOINT(10, 10)) as azimuth2,
               \`@@BQ_PREFIX@@measurements.ST_AZIMUTH\`(ST_GEOGPOINT(0, 0), ST_GEOGPOINT(0, 10)) as azimuth3,
               \`@@BQ_PREFIX@@measurements.ST_AZIMUTH\`(ST_GEOGPOINT(0, 0), ST_GEOGPOINT(0, -10)) as azimuth4
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].azimuth1).toEqual(90);
    expect(rows[0].azimuth2).toEqual(44.56145141325769);
    expect(rows[0].azimuth3).toEqual(0);
    expect(rows[0].azimuth4).toEqual(180);
});

test('ST_AZIMUTH should return NULL if any NULL mandatory argument', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@measurements.ST_AZIMUTH\`(NULL, ST_GEOGPOINT(-4.70325, 41.4167)) as azimuth1,
               \`@@BQ_PREFIX@@measurements.ST_AZIMUTH\`(ST_GEOGPOINT(-3.70325, 40.4167), NULL) as azimuth2
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].azimuth1).toEqual(null);
    expect(rows[0].azimuth2).toEqual(null);
});
