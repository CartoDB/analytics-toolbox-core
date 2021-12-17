const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('Works as expected', async () => {
    const query = `
        WITH ids AS
        (
            -- Invalid parameters
            SELECT 1 AS id, NULL as hid UNION ALL
            SELECT 2 AS id, 'ff283473fffffff' as hid UNION ALL

            -- Valid parameters
            SELECT 3 AS id, '85283473fffffff' as hid UNION ALL
            SELECT 4 AS id, '8075fffffffffff' as hid
        )
        SELECT
            id,
            \`@@BQ_PREFIX@@carto.H3_ISVALID\`(hid) as valid
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(4);
    expect(rows[0].valid).toEqual(false);
    expect(rows[1].valid).toEqual(false);
    expect(rows[2].valid).toEqual(true);
    expect(rows[3].valid).toEqual(true);
});