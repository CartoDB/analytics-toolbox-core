const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_DISTANCE should work', async () => {
    const query = 'SELECT `@@BQ_DATASET@@.QUADBIN_DISTANCE`(5207251884775047167, 5207128739472736255) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual(1);
});