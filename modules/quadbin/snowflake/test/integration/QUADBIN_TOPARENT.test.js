const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_TOPARENT should work', async () => {
    const query = 'SELECT CAST(QUADBIN_TOPARENT(5209574053332910079, 3) AS STRING) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('5205105638077628415');
});

test('H3_TOPARENT works as expected with invalid data', async () => {
    const query = `
        WITH ids AS
        (
            -- Invalid parameters
            SELECT 1 AS id, NULL as hid UNION ALL
            SELECT 2 AS id, '0xff283473fffffff' as hid
        )
        SELECT
            id,
            H3_TOPARENT(hid, 1) as parent
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(2);
    expect(rows[0].PARENT).toEqual(null);
    expect(rows[0].PARENT).toEqual(null);
});