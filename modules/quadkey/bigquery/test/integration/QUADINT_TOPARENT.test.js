const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADINT_TOPARENT should work at any level of zoom', async () => {
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
            \`@@BQ_PREFIX@@quadkey.QUADINT_FROMGEOGPOINT\`(ST_GEOGPOINT(long, lat), zoom - 1) AS expectedParent,
            \`@@BQ_PREFIX@@quadkey.QUADINT_TOPARENT\`(
                \`@@BQ_PREFIX@@quadkey.QUADINT_FROMGEOGPOINT\`(ST_GEOGPOINT(long, lat), zoom), zoom - 1) AS parent
        FROM zoomContext
    )
    WHERE parent != expectedParent`;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});

test('QUADINT_TOPARENT should reject quadints with lower level of zoom than the passed resolution', async () => {
    let query = 'SELECT `@@BQ_PREFIX@@quadkey.QUADINT_TOPARENT`(291,4)';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT `@@BQ_PREFIX@@quadkey.QUADINT_TOPARENT`(3280010,11)';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT `@@BQ_PREFIX@@quadkey.QUADINT_TOPARENT`(52432014,15)';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADINT_TOPARENT should fail with NULL argument', async () => {
    let query = 'SELECT `@@BQ_PREFIX@@quadkey.QUADINT_TOPARENT`(NULL, 10);';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT `@@BQ_PREFIX@@quadkey.QUADINT_TOPARENT`(322, NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});