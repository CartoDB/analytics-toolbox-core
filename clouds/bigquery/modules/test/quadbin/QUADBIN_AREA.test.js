const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_AREA should work', async () => {
    const query = 'SELECT `@@BQ_DATASET@@.QUADBIN_AREA`(5207251884775047167) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toBeCloseTo(4861439445256.75, 0);
});

test('QUADBIN_AREA should return NULL for NULL input', async () => {
    const query = 'SELECT `@@BQ_DATASET@@.QUADBIN_AREA`(NULL) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual(null);
});

test('QUADBIN_AREA should work for different zoom levels', async () => {
    const query = `
        SELECT
            \`@@BQ_DATASET@@.QUADBIN_AREA\`(5192650370358181887) AS level0_area,
            \`@@BQ_DATASET@@.QUADBIN_AREA\`(5193776270265024511) AS level1_area,
            \`@@BQ_DATASET@@.QUADBIN_AREA\`(5207251884775047167) AS level4_area
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);

    // Higher zoom levels should have smaller areas
    expect(rows[0].level0_area).toBeGreaterThan(rows[0].level1_area);
    expect(rows[0].level1_area).toBeGreaterThan(rows[0].level4_area);

    // Check that all values are positive
    expect(rows[0].level0_area).toBeGreaterThan(0);
    expect(rows[0].level1_area).toBeGreaterThan(0);
    expect(rows[0].level4_area).toBeGreaterThan(0);
});