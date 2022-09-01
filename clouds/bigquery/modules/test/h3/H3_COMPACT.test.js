const { runQuery } = require('../../../common/test-utils');

test('Work as expected with NULLish values', async () => {
    let query = `
        SELECT 
        \`@@BQ_DATASET@@.H3_COMPACT\`(NULL) as c,
        \`@@BQ_DATASET@@.H3_UNCOMPACT\`(NULL, 5) as u
    `;

    let rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].c).toEqual([]);
    expect(rows[0].u).toEqual([]);

    query = `
        SELECT
        \`@@BQ_DATASET@@.H3_COMPACT\`([]) as c,
        \`@@BQ_DATASET@@.H3_UNCOMPACT\`([], 5) as u
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].c).toEqual([]);
    expect(rows[0].u).toEqual([]);
});

test('Work with polyfill arrays', async () => {
    const query = `
        WITH poly AS
        (
        SELECT \`@@BQ_DATASET@@.H3_POLYFILL\`(ST_GEOGFROMTEXT('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))'), 9) AS v
        )
        SELECT
        ARRAY_LENGTH(v) AS original,
        ARRAY_LENGTH(\`@@BQ_DATASET@@.H3_COMPACT\`(v)) AS compacted,
        ARRAY_LENGTH(\`@@BQ_DATASET@@.H3_UNCOMPACT\`(\`@@BQ_DATASET@@.H3_COMPACT\`(v), 9)) AS uncompacted
        FROM poly
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].original).toEqual(1253);
    expect(rows[0].compacted).toEqual(209);
    expect(rows[0].uncompacted).toEqual(1253);
});