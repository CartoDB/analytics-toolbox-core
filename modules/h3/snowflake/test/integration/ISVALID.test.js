const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('Works as expected', async () => {
    const query = `
        WITH ids AS
        (
            -- Invalid parameters
            SELECT 1 AS id, NULL as hid UNION ALL
            SELECT 2 AS id, 'ff283473fffffff' as hid UNION ALL
        
            -- Valid parameters
            SELECT 3 AS id, '85283473fffffff' as hid UNION ALL
            SELECT 4 AS id, ST_ASH3(ST_POINT(-122.0553238, 37.3615593), 5)::STRING as hid
        )
        SELECT
            id,
            ISVALID(hid) as valid
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(4);
    expect(rows[0].VALID).toEqual(false);
    expect(rows[1].VALID).toEqual(false);
    expect(rows[2].VALID).toEqual(true);
    expect(rows[3].VALID).toEqual(true);
});