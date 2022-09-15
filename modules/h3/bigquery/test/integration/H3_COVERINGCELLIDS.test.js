const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('H3_COVERINGCELLIDS returns the proper INT64s', async () => {
    const query = `
        WITH T AS (
          SELECT
          ST_MAKELINE(ST_GEOGPOINT(0.9,45),ST_GEOGPOINT(1,45.1)) geom, 0 id
          UNION ALL
          SELECT
          ST_BUFFER(ST_GEOGPOINT(1,45),5000) geom, 1 id
        )
        SELECT ARRAY_LENGTH(\`@@BQ_PREFIX@@carto.H3_COVERINGCELLIDS\`(geom, 11)) AS id_count
        FROM T
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(2);
    expect(rows.map((r) => r.id_count)).toEqual([
        359,
        38999
    ]);
});