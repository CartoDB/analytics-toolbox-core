const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_AREA should work', async () => {
    const query = 'SELECT QUADBIN_AREA(5207251884775047167) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toBeCloseTo(4507012722233371.0, 0);
});

test('QUADBIN_AREA should return NULL for NULL input', async () => {
    const query = 'SELECT QUADBIN_AREA(NULL) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(null);
});

test('QUADBIN_AREA should work for different zoom levels', async () => {
    const query = `
        SELECT
            QUADBIN_AREA(5192650370358181887) AS LEVEL0_AREA,
            QUADBIN_AREA(5193776270265024511) AS LEVEL1_AREA,
            QUADBIN_AREA(5207251884775047167) AS LEVEL4_AREA
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);

    // Higher zoom levels should have smaller areas
    expect(rows[0].LEVEL0_AREA).toBeGreaterThan(rows[0].LEVEL1_AREA);
    expect(rows[0].LEVEL1_AREA).toBeGreaterThan(rows[0].LEVEL4_AREA);

    // Check that all values are positive
    expect(rows[0].LEVEL0_AREA).toBeGreaterThan(0);
    expect(rows[0].LEVEL1_AREA).toBeGreaterThan(0);
    expect(rows[0].LEVEL4_AREA).toBeGreaterThan(0);
});