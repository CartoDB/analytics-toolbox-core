const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADINT_TOLIST_FROMLONGLATRESOLUTION should work', async () => {
    const query = `
        SELECT
            \`@@BQ_PREFIX@@quadkey.QUADINT_TOLIST_FROMLONGLATRESOLUTION\`(-45,30,2,10,2,5) AS agg1,
            \`@@BQ_PREFIX@@quadkey.QUADINT_TOLIST_FROMLONGLATRESOLUTION\`(150,-30,16,18,1,5) AS agg2,
            \`@@BQ_PREFIX@@quadkey.QUADINT_TOLIST_FROMLONGLATRESOLUTION\`(170,-80,20,24,1,4) AS agg3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].agg1).toEqual([
        { id: 214535, z: 2, x: 1, y: 1 },
        { id: 3463177, z: 4, x: 6, y: 6 },
        { id: 55336971, z: 6, x: 24, y: 26 },
        { id: 885882893, z: 8, x: 96, y: 105 },
        { id: 14176092175, z: 10, x: 384, y: 422 }
    ]);
    expect(rows[0].agg2).toEqual([
        { id: 82672746146485, z: 16, x: 60074, y: 38497 },
        { id: 330690861552982, z: 17, x: 120149, y: 76994 },
        { id: 1322763200146103, z: 18, x: 240298, y: 153989 }
    ]);
    expect(rows[0].agg3).toEqual([
        { id: 7996056564167128, z: 20, x: 1019448, y: 930863 },
        { id: 31984226286494616, z: 21, x: 2038897, y: 1861726 },
        { id: 127936905205630750, z: 22, x: 4077795, y: 3723453 },
        { id: 511747616646860350, z: 23, x: 8155591, y: 7446907 },
        { id: 2046990466826050600, z: 24, x: 16311182, y: 14893815 }
    ]);
});

test('QUADINT_TOLIST_FROMLONGLATRESOLUTION should return [] with NULL latitud/longitud', async () => {
    const query = `
        SELECT
            \`@@BQ_PREFIX@@quadkey.QUADINT_TOLIST_FROMLONGLATRESOLUTION\`(NULL,10,10,12,1,5) AS agg1,
            \`@@BQ_PREFIX@@quadkey.QUADINT_TOLIST_FROMLONGLATRESOLUTION\`(10,NULL,10,12,1,5) AS agg2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].agg1).toEqual([]);
    expect(rows[0].agg2).toEqual([]);
});