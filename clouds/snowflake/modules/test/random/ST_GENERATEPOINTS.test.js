const { runQuery } = require('../../../common/test-utils');

test('ST_GENERATEPOINTS should work', async () => {
    const query = `SELECT
        @@SF_SCHEMA@@.ST_GENERATEPOINTS(TO_GEOGRAPHY('POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))'), 10) AS random
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].RANDOM.length).toEqual(10);
});