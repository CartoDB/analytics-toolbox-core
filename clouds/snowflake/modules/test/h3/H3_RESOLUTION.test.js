const { runQuery } = require('../../../common/test-utils');

test('Returns NULL with invalid parameters', async () => {
    const query = `
        WITH ids AS
        (
            SELECT 1 AS id, NULL as hid UNION ALL
            SELECT 2 AS id, 'ff283473fffffff' as hid
        )
        SELECT
            id,
            H3_RESOLUTION(hid) as resolution
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(2);
    expect(rows[0].RESOLUTION).toEqual(null);
    expect(rows[1].RESOLUTION).toEqual(null);
});

test('Returns the expected resolution', async () => {
    const query = `
        WITH ids AS
        (
            SELECT 1 AS id, '85283473fffffff' as hid, 5 AS expected UNION ALL
            SELECT 2 AS id, '81623ffffffffff' as hid, 1 AS expected
        )
        SELECT
            *,
            H3_RESOLUTION(hid) as resolution
        FROM ids
        WHERE expected != H3_RESOLUTION(hid)
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});
