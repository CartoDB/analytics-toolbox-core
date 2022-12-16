const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_FROMQUADKEY should work', async () => {
    const query = `SELECT [
        CAST(\`@@BQ_DATASET@@.QUADBIN_FROMQUADKEY\`('') AS STRING),
        CAST(\`@@BQ_DATASET@@.QUADBIN_FROMQUADKEY\`('0') AS STRING),
        CAST(\`@@BQ_DATASET@@.QUADBIN_FROMQUADKEY\`('13020310') AS STRING),
        CAST(\`@@BQ_DATASET@@.QUADBIN_FROMQUADKEY\`('0231001222') AS STRING)
    ] AS output`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual(['5192650370358181887', '5193776270265024511', '5226184719091105791', '5233974874938015743']);
});