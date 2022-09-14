const { runQuery } = require('../../../common/test-utils');

test('QUADKEY conversion should work', async () => {
    const query = `SELECT
        \`@@BQ_DATASET@@.QUADINT_TOQUADKEY\`(\`@@BQ_DATASET@@.QUADINT_FROMZXY\`(2, 1, 1)) AS quadkey1,
        \`@@BQ_DATASET@@.QUADINT_TOQUADKEY\`(\`@@BQ_DATASET@@.QUADINT_FROMZXY\`(6, 40, 55)) AS quadkey2,
        \`@@BQ_DATASET@@.QUADINT_TOQUADKEY\`(\`@@BQ_DATASET@@.QUADINT_FROMZXY\`(12, 1960, 3612)) AS quadkey3,
        \`@@BQ_DATASET@@.QUADINT_TOQUADKEY\`(\`@@BQ_DATASET@@.QUADINT_FROMZXY\`(18, 131621, 65120)) AS quadkey4,
        \`@@BQ_DATASET@@.QUADINT_TOQUADKEY\`(\`@@BQ_DATASET@@.QUADINT_FROMZXY\`(24, 9123432, 159830174)) AS quadkey5,
        \`@@BQ_DATASET@@.QUADINT_TOQUADKEY\`(\`@@BQ_DATASET@@.QUADINT_FROMZXY\`(29, 389462872, 207468912)) AS quadkey6`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].quadkey1).toEqual('03');
    expect(rows[0].quadkey2).toEqual('321222');
    expect(rows[0].quadkey3).toEqual('233110123200');
    expect(rows[0].quadkey4).toEqual('102222223002300101');
    expect(rows[0].quadkey5).toEqual('300012312213011021123220');
    expect(rows[0].quadkey6).toEqual('12311021323123033301303231000');
});

test('QUADKEY should be able to encode/decode between quadint and quadkey at any level of zoom', async () => {
    const query = `WITH tileContext AS (
            WITH zoomValues AS (
                SELECT zoom FROM UNNEST (GENERATE_ARRAY(0,29)) AS zoom
            )
            SELECT *
            FROM
                zoomValues,
                UNNEST(GENERATE_ARRAY(0,CAST(pow(2, zoom) - 1 AS INT64),COALESCE(NULLIF(CAST(pow(2, zoom)*0.02 AS INT64),0),1))) tileX,
                UNNEST(GENERATE_ARRAY(0,CAST(pow(2, zoom) - 1 AS INT64),COALESCE(NULLIF(CAST(pow(2, zoom)*0.02 AS INT64),0),1))) tileY
        )
        SELECT *
        FROM (
            SELECT *,
                \`@@BQ_DATASET@@.QUADINT_TOZXY\`(
                    \`@@BQ_DATASET@@.QUADINT_FROMQUADKEY\`(
                        \`@@BQ_DATASET@@.QUADINT_TOQUADKEY\`(
                            \`@@BQ_DATASET@@.QUADINT_FROMZXY\`(zoom, tileX, tileY)))) AS decodedQuadkey
            FROM tileContext
        )
        WHERE tileX != decodedQuadkey.x OR tileY != decodedQuadkey.y OR zoom != decodedQuadkey.z`;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});

test('QUADINT_TOQUADKEY should fail with NULL argument', async () => {
    let query = 'SELECT `@@BQ_DATASET@@.QUADINT_TOQUADKEY`(NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});