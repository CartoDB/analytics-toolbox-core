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
            SELECT 1 AS id, H3_CENTER('85283473fffffff') as bounds, ST_GEOGRAPHYFROMWKB('010100000049ada5f17c7e5ec0c63013f542ac4240') AS expected UNION ALL
            SELECT 2 AS id, H3_CENTER('81623ffffffffff') as bounds, ST_GEOGRAPHYFROMWKB('01010000001ead77b42f144d4007c4ac6d0ae52440') AS expected
        )
        SELECT
            *            
        FROM ids
        WHERE ST_ASBINARY(bounds) != ST_ASBINARY(expected) or bounds is null
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});