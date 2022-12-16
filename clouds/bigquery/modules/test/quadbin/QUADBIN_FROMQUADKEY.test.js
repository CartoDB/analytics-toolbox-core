const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_FROMQUADKEY should work', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.QUADBIN_FROMQUADKEY`("0231001222") AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5233974874938015743');
});
