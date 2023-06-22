const { runQuery } = require('../../../common/test-utils');

test('_FROM_BASE should work', async () => {
    const query = `
        SELECT
            ARRAY_AGG(_FROM_BASE($1, $2)) AS OUTPUT
        FROM (
            VALUES
                (0,4),
                (13020310,4)
        )`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(["0", "29236"]);
});