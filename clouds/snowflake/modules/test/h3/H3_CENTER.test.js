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
            H3_CENTER(hid) as bounds
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(2);
    expect(rows[0].BOUNDS).toEqual(null);
    expect(rows[1].BOUNDS).toEqual(null);
});

test('Returns NULL the expected geography', async () => {
    const query = `
        WITH ids AS
        (
            SELECT 1 AS id, H3_CENTER('85283473fffffff') as bounds, TO_GEOGRAPHY('POINT(-121.9763759725512 37.34579337536848)') AS expected UNION ALL
            SELECT 2 AS id, H3_CENTER('81623ffffffffff') as bounds, TO_GEOGRAPHY('POINT(58.1577058395726 10.447345187511)') AS expected
        )
        SELECT
            *            
        FROM ids
        WHERE ST_ASBINARY(expected) != ST_ASBINARY(expected) or bounds is null
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});