const { runQuery } = require('../../../../../common/bigquery/test-utils');

const quadintsFixturesOut = require('./longlat_asquadint_fixtures/out/quadints');

test('LONGLAT_ASQUADINT should not fail at any level of zoom', async () => {
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
        SELECT \`@@BQ_PREFIX@@quadkey.LONGLAT_ASQUADINT\`(long, lat, zoom) AS quadints
        FROM zoomContext`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(9425);
    expect(rows.map(r => r.quadints).sort()).toEqual(quadintsFixturesOut.value);
});

test('LONGLAT_ASQUADINT should fail to encode quadints at zooms bigger than 29 or smaller than 0', async () => {
    let query = 'SELECT `@@BQ_PREFIX@@quadkey.LONGLAT_ASQUADINT`(100, 100, 30)';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT `@@BQ_PREFIX@@quadkey.LONGLAT_ASQUADINT`(100, 100, -1)';
    await expect(runQuery(query)).rejects.toThrow();
});

test('LONGLAT_ASQUADINT should fail if any NULL argument', async () => {
    let query = 'SELECT `@@BQ_PREFIX@@quadkey.LONGLAT_ASQUADINT`(NULL, 10, 10);';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT `@@BQ_PREFIX@@quadkey.LONGLAT_ASQUADINT`(10, NULL, 10);';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT `@@BQ_PREFIX@@quadkey.LONGLAT_ASQUADINT`(10, 10, NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});