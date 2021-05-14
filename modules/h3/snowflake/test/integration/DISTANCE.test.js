const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('Works as expected with invalid input', async () => {
    const query = `
        WITH ids AS
        (
            -- Invalid parameters
            SELECT 1 AS id, NULL as hid1, '85283473fffffff' AS hid2 UNION ALL
            SELECT 2 AS id, 'ff283473fffffff' as hid1, '85283473fffffff' AS hid2 UNION ALL
            SELECT 3 AS id, '85283473fffffff' as hid1, NULL AS hid2 UNION ALL
            SELECT 4 AS id, '85283473fffffff' as hid1, 'ff283473fffffff' AS hid2 UNION ALL
        
            -- Self
            SELECT 5 AS id, '8928308280fffff' as hid1, '8928308280fffff' as hid2
        )
        SELECT
            id,
            @@SF_PREFIX@@h3.DISTANCE(hid1, hid2) as distance
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(5);
    expect(rows[0].DISTANCE).toEqual(null);
    expect(rows[1].DISTANCE).toEqual(null);
    expect(rows[2].DISTANCE).toEqual(null);
    expect(rows[3].DISTANCE).toEqual(null);
    expect(rows[4].DISTANCE).toEqual(0);
});

test('Works as expected with valid input', async () => {
    const query = `
        WITH distances AS
        (
            SELECT seq4() AS distance
            FROM TABLE(generator(rowcount => 5))
        ),
        ids AS
        (
            SELECT
                distance,
                '8928308280fffff' as hid1,
                hid2.value as hid2
            FROM
                distances,
                lateral FLATTEN(input =>@@SF_PREFIX@@h3.HEXRING('8928308280fffff', distance)) hid2
        )
        SELECT @@SF_PREFIX@@h3.DISTANCE(hid1, hid2) as calculated_distance, *
        FROM ids
        WHERE @@SF_PREFIX@@h3.DISTANCE(hid1, hid2) != distance;
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});
