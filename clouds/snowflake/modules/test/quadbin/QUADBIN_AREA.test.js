const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_AREA should work', async () => {
    const query = 'SELECT QUADBIN_AREA(5207251884775047167) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toBeCloseTo(4507012722233.0, 0);
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
            QUADBIN_AREA(5207251884775047167) AS TEST_AREA,
            QUADBIN_AREA(5209574053332910079) AS ANOTHER_AREA
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);

    // Check that all values are positive
    expect(rows[0].TEST_AREA).toBeGreaterThan(0);
    expect(rows[0].ANOTHER_AREA).toBeGreaterThan(0);
});