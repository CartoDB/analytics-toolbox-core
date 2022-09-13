const { runQuery } = require('../../../common/test-utils');

test('QUADINT_SIBLING should work at any level of zoom', async () => {
    const query = `WITH zoomContext AS (
            WITH zoomValues AS (
                SELECT zoom FROM UNNEST (GENERATE_ARRAY(0,29)) AS zoom
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
        rightSiblingContext AS (
            SELECT *,
            \`@@BQ_DATASET@@.QUADINT_SIBLING\`(expectedQuadint,'right') AS rightSibling
            FROM expectedQuadintContext
            WHERE expectedQuadint IS NOT NULL
        ),
        upSiblingContext AS (
            SELECT *,
            \`@@BQ_DATASET@@.QUADINT_SIBLING\`(rightSibling,'up') AS upSibling
            FROM rightSiblingContext
            WHERE rightSibling IS NOT NULL
        ),
        leftSiblingContext AS (
            SELECT *,
            \`@@BQ_DATASET@@.QUADINT_SIBLING\`(upSibling,'left') AS leftSibling
            FROM upSiblingContext
            WHERE upSibling IS NOT NULL
        ),
        downSiblingContext AS (
            SELECT *,
            \`@@BQ_DATASET@@.QUADINT_SIBLING\`(leftSibling,'down') AS downSibling
            FROM leftSiblingContext
            WHERE leftSibling IS NOT NULL
        )
        SELECT *
        FROM downSiblingContext
        WHERE downSibling != expectedQuadint`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});

test('QUADINT_SIBLING should fail if any NULL argument', async () => {
    let query = 'SELECT `@@BQ_DATASET@@.QUADINT_SIBLING`(NULL, "up")';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT `@@BQ_DATASET@@.QUADINT_SIBLING`(322, NULL)';
    await expect(runQuery(query)).rejects.toThrow();
});