const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_POLYFILL_TABLE should work', async () => {
    const outputTable = 'quadbin_polyfill_table_test';
    await runQuery(`DROP TABLE IF EXISTS ${outputTable}`);
    await runQuery(`CALL QUADBIN_POLYFILL_TABLE(
        'SELECT ST_GEOGFROMTEXT(''POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'') AS geom',
        17, 'intersects',
        '${outputTable}'
    )`);
    const rows = await runQuery(`SELECT ARRAY_TO_STRING(
        ARRAY_AGG(quadbin) WITHIN GROUP (ORDER BY quadbin), ','
    ) AS OUTPUT FROM ${outputTable}`);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(
        '5265786693153193983,5265786693163941887,5265786693164204031,5265786693164466175,5265786693164728319,5265786693165514751');
    await runQuery(`DROP TABLE IF EXISTS ${outputTable}`);
});