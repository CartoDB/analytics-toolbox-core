const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('ST_AZIMUTH should work', async () => {
    const query = `
        SELECT ST_AZIMUTH(ST_POINT(0, 0), ST_POINT(10, 0)) as azimuth1,
               ST_AZIMUTH(ST_POINT(0, 0), ST_POINT(10, 10)) as azimuth2,
               ST_AZIMUTH(ST_POINT(0, 0), ST_POINT(0, 10)) as azimuth3,
               ST_AZIMUTH(ST_POINT(0, 0), ST_POINT(0, -10)) as azimuth4
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].AZIMUTH1).toEqual(90);
    expect(rows[0].AZIMUTH2).toEqual(44.561451413);
    expect(rows[0].AZIMUTH3).toEqual(0);
    expect(rows[0].AZIMUTH4).toEqual(180);
});

test('ST_AZIMUTH should return NULL if any NULL mandatory argument', async () => {
    const query = `
        SELECT ST_AZIMUTH(NULL, ST_POINT(-4.70325, 41.4167)) as azimuth1,
               ST_AZIMUTH(ST_POINT(-3.70325, 40.4167), NULL) as azimuth2
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].AZIMUTH1).toEqual(null);
    expect(rows[0].AZIMUTH2).toEqual(null);
});