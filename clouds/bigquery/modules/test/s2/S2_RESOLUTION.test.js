const { runQuery } = require('../../../common/test-utils');

test('Returns the expected resolution', async () => {
    const query = `
        WITH ids AS
        (
            SELECT 1 AS id, -6432928348669739008 as hid, 11 AS expected UNION ALL
            SELECT 2 AS id, -6432928554828169216 as hid, 12 AS expected
        )
        SELECT
            *,
            \`@@BQ_DATASET@@.S2_RESOLUTION\`(hid) as resolution
        FROM ids
        WHERE expected != \`@@BQ_DATASET@@.S2_RESOLUTION\`(hid)
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});