const { runQuery } = require('../../../common/test-utils');

test('H3_TOCHILDREN works as expected with invalid data', async () => {
    const query = `
        WITH ids AS
        (
            -- Invalid parameters
            SELECT 1 AS id, NULL as hid UNION ALL
            SELECT 2 AS id, 'ff283473fffffff' as hid
        )
        SELECT
            id,
            \`@@BQ_DATASET@@.H3_TOCHILDREN\`(hid, 1) as parent
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(2);
    expect(rows[0].parent).toEqual([]);
    expect(rows[1].parent).toEqual([]);
});

test('List children correctly', async () => {
    const query = `
        WITH ids AS
        (
            SELECT
                \`@@BQ_DATASET@@.H3_FROMGEOGPOINT\`(ST_GEOGPOINT(-122.409290778685, 37.81331899988944), 7) AS hid
        )
        SELECT
            ARRAY_LENGTH(\`@@BQ_DATASET@@.H3_TOCHILDREN\`(hid, 8)) AS length_children,
            ARRAY_LENGTH(\`@@BQ_DATASET@@.H3_TOCHILDREN\`(hid, 9)) AS length_grandchildren
        FROM ids
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].length_children).toEqual(7);
    expect(rows[0].length_grandchildren).toEqual(49);
});

test('Same resolution lists self', async () => {
    const query = `
        WITH ids AS
        (
            SELECT '87283080dffffff' as hid
        )
        SELECT
            \`@@BQ_DATASET@@.H3_TOCHILDREN\`(hid, 7) AS self_children
        FROM ids
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].self_children).toEqual([ '87283080dffffff' ]);
});

test('Coarser resolution returns empty array', async () => {
    const query = `
        WITH ids AS
        (
            SELECT
                \`@@BQ_DATASET@@.H3_FROMGEOGPOINT\`(ST_GEOGPOINT(-122.409290778685, 37.81331899988944), 7) AS hid
        )
        SELECT
            \`@@BQ_DATASET@@.H3_TOCHILDREN\`(hid, 6) AS top_children
        FROM ids
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].top_children).toEqual([ ]);
});