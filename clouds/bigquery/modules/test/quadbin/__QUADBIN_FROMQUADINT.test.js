const { runQuery } = require('../../../common/test-utils');

test('__QUADBIN_FROMQUADINT.test should work', async () => {
    const query = 'SELECT CAST(`@@BQ_DATASET@@.__QUADBIN_FROMQUADINT`(12521547919) AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5256684166837174271');
});