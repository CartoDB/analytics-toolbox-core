const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_POLYFILL should work', async () => {
    const query = `SELECT ARRAY_TO_STRING(QUADBIN_POLYFILL(ST_GEOGFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
    17), ',') AS OUTPUT`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    const out = (rows[0].OUTPUT).split(',').sort().join(',')
    expect(out).toEqual(
        '5265786693153193983,5265786693163941887,5265786693164204031,5265786693164466175,5265786693164728319,5265786693165514751');
});
