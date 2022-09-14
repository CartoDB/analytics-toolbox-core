const { runQuery } = require('../../../common/test-utils');

test('QUADINT_TOCHILDREN should work at any level of zoom', async () => {
    const query = `WITH zoomContext AS (
            WITH zoomValues AS (
                SELECT zoom FROM UNNEST (GENERATE_ARRAY(0,28)) AS zoom
            )
            SELECT *
            FROM
                zoomValues,
                UNNEST(GENERATE_ARRAY(0,CAST(pow(2, zoom) - 1 AS INT64),COALESCE(NULLIF(CAST(pow(2, zoom)*0.02 AS INT64),0),1))) tileX,
                UNNEST(GENERATE_ARRAY(0,CAST(pow(2, zoom) - 1 AS INT64),COALESCE(NULLIF(CAST(pow(2, zoom)*0.02 AS INT64),0),1))) tileY
        ),
        expectedQuadintContext AS (
            SELECT *,
            \`@@BQ_DATASET@@.QUADINT_FROMZXY\`(zoom, tileX, tileY) AS expectedQuadint,
            FROM zoomContext
        ),
        childrenContext AS (
            SELECT *,
            \`@@BQ_DATASET@@.QUADINT_TOCHILDREN\`(expectedQuadint, zoom + 1) AS children
            FROM expectedQuadintContext 
        )
        SELECT *
        FROM (
            SELECT expectedQuadint,
            \`@@BQ_DATASET@@.QUADINT_TOPARENT\`(child, zoom) AS currentQuadint
            FROM childrenContext, UNNEST(children) AS child
        )
        WHERE currentQuadint != expectedQuadint`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});

test('QUADINT_TOCHILDREN should reject quadints at zoom 29', async () => {
    const query = 'SELECT `@@BQ_DATASET@@.QUADINT_TOCHILDREN`(4611686027017322525,30)';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADINT_TOCHILDREN should fail with NULL arguments', async () => {
    let query = 'SELECT `@@BQ_DATASET@@.QUADINT_TOCHILDREN`(NULL, 1);';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT `@@BQ_DATASET@@.QUADINT_TOCHILDREN`(322, NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});