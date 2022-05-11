const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADINT_RESOLUTION should work at any level of zoom', async () => {
    const query = `WITH zoomContext AS (
        WITH zoomValues AS (
            SELECT zoom FROM UNNEST (GENERATE_ARRAY(1,29)) AS zoom
        )
        SELECT *
        FROM
            zoomValues,
            UNNEST(GENERATE_ARRAY(-90,90,15)) lat,
            UNNEST(GENERATE_ARRAY(-180,180,15)) long
    )
    SELECT *
    FROM (
        SELECT *,
            zoom AS expectedResolution,
            \`@@BQ_PREFIX@@carto.QUADINT_RESOLUTION\`(
                \`@@BQ_PREFIX@@carto.QUADINT_FROMGEOGPOINT\`(ST_GEOGPOINT(long, lat), zoom)) AS resolution
        FROM zoomContext
    )
    WHERE resolution != expectedResolution`;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});