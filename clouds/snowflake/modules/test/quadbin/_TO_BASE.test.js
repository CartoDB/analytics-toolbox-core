const { runQuery } = require('../../../common/test-utils');

test('_TO_BASE should work', async () => {
    const query = `
        SELECT
            ARRAY_AGG(_TO_BASE($1, $2)::STRING) AS OUTPUT
        FROM (
            VALUES
                (4,4),
                (4,3),
                (3,4)
        )`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(['10', '11', '3']);
});