const { runQuery } = require('../../../../../common/bigquery/test-utils');

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
    \`@@BQ_PREFIX@@h3.DISTANCE\`(hid1, hid2) as distance
FROM ids
ORDER BY id ASC
`;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(5);
    expect(rows[0].distance).toEqual(null);
    expect(rows[1].distance).toEqual(null);
    expect(rows[2].distance).toEqual(null);
    expect(rows[3].distance).toEqual(null);
    expect(rows[4].distance).toEqual(0);
});

test('Works as expected with valid input', async () => {
    const query = `
WITH distances AS
(
SELECT distance FROM UNNEST(GENERATE_ARRAY(0, 4, 1)) distance
),
ids AS
(
SELECT
    distance,
    '8928308280fffff' as hid1,
    hid2
FROM
    distances,
    UNNEST (\`@@BQ_PREFIX@@h3.HEXRING\`('8928308280fffff', distance)) hid2
)
SELECT \`@@BQ_PREFIX@@h3.DISTANCE\`(hid1, hid2) as calculated_distance, *
FROM ids
WHERE \`@@BQ_PREFIX@@h3.DISTANCE\`(hid1, hid2) != distance;
`;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});
