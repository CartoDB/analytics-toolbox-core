const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_TOQUADKEY should work', async () => {
    const query = `SELECT [
        QUADBIN_TOQUADKEY(5192650370358181887),
        QUADBIN_TOQUADKEY(5193776270265024511),
        QUADBIN_TOQUADKEY(5226184719091105791),
        QUADBIN_TOQUADKEY(5233974874938015743)
    ] AS OUTPUT`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(['', '0', '13020310', '0231001222']);
});