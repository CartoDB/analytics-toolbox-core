const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('TOPARENT works as expected with invalid data', async () => {
    const query = `
        WITH ids AS
        (
            -- Invalid parameters
            SELECT 1 AS id, NULL as hid UNION ALL
            SELECT 2 AS id, 'ff283473fffffff' as hid
        )
        SELECT
            id,
            \`@@BQ_PREFIX@@h3.TOPARENT\`(hid, 1) as parent
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(2);
    expect(rows[0].parent).toEqual(null);
    expect(rows[0].parent).toEqual(null);
});

test('Equivalent to previous resolution level', async () => {
/* From h3-js tests:
    // NB: This test will not work with every hexagon, it has to be a location
    // that does not fall in the margin of error between the 7 children and
    // the parent's true boundaries at every resolution
    */
    const query = `
        WITH ids AS
        (
            SELECT
                ST_GEOGPOINT(-122.409290778685, 37.81331899988944) as point,
                resolution
            FROM UNNEST(GENERATE_ARRAY(1, 10, 1)) resolution
        )
        SELECT
            *
        FROM ids
        WHERE
            \`@@BQ_PREFIX@@h3.ST_ASH3\`(point, resolution) != \`@@BQ_PREFIX@@h3.TOPARENT\`(\`@@BQ_PREFIX@@h3.ST_ASH3\`(point, resolution + 1), resolution) OR
            \`@@BQ_PREFIX@@h3.ST_ASH3\`(point, resolution) != \`@@BQ_PREFIX@@h3.TOPARENT\`(\`@@BQ_PREFIX@@h3.ST_ASH3\`(point, resolution + 2), resolution)
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});