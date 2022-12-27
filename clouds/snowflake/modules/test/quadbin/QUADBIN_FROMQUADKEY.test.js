const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_FROMQUADKEY should work', async () => {
    const query = `SELECT [
        CAST(QUADBIN_FROMQUADKEY('') AS STRING),
        CAST(QUADBIN_FROMQUADKEY('0') AS STRING),
        CAST(QUADBIN_FROMQUADKEY('13020310') AS STRING),
        CAST(QUADBIN_FROMQUADKEY('0231001222') AS STRING)
    ] AS OUTPUT`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(['5192650370358181887', '5193776270265024511', '5226184719091105791', '5233974874938015743']);
});