const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('Returns NULL with invalid parameters', async () => {
    const query = `
        WITH ids AS
        (
            SELECT 1 AS id, NULL as hid UNION ALL
            SELECT 2 AS id, 'ff283473fffffff' as hid
        )
        SELECT
            id,
            \`@@BQ_PREFIX@@carto.H3_CENTER\`(hid) as bounds
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(2);
    expect(rows[0].bounds).toEqual(null);
    expect(rows[1].bounds).toEqual(null);
});

test('Returns NULL the expected geography', async () => {
    const query = `
        WITH ids AS
        (
            SELECT 1 AS id, \`@@BQ_PREFIX@@carto.H3_CENTER\`('85283473fffffff') as bounds, ST_GEOGFROMTEXT('POINT(-121.9763759725512 37.34579337536848)') AS expected UNION ALL
            SELECT 2 AS id, \`@@BQ_PREFIX@@carto.H3_CENTER\`('81623ffffffffff') as bounds, ST_GEOGFROMTEXT('POINT(58.1577058395726 10.447345187511)') AS expected
        )
        SELECT
            *            
        FROM ids
        WHERE NOT ST_EQUALS(expected, bounds) or bounds is null
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});