const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_TOCHILDREN should work', async () => {
    const query = 'SELECT TO_JSON(QUADBIN_TOCHILDREN(5209574053332910079, 5)) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('["5214064458820747263","5214073254913769471","5214068856867258367","5214077652960280575"]');
});