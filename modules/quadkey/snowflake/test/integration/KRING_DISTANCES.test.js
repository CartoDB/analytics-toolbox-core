const { runQuery, sortByKey } = require('../../../../../common/snowflake/test-utils');

test('KRING_DISTANCES should work', async () => {
    const query = `
        SELECT @@SF_PREFIX@@quadkey.KRING_DISTANCES(GET(VALUE,'origin'), GET(VALUE,'size')) as kring_distances
        FROM LATERAL FLATTEN(input => ARRAY_CONSTRUCT(
            OBJECT_CONSTRUCT('origin', 162, 'size', 1),
            OBJECT_CONSTRUCT('origin', 12070922, 'size', 1),
            OBJECT_CONSTRUCT('origin', 12070922, 'size', 2)
        ))
    `;
    const rows = await runQuery(query);
    expect(sortByKey(rows[0].KRING_DISTANCES,'index')).toEqual(
        sortByKey([
            { index: '162', distance: 0 },
            { index: '322', distance: 1 },
            { index: '290', distance: 1 },
            { index: '258', distance: 1 },
            { index: '194', distance: 1 },
            { index: '130', distance: 1 },
            { index: '66', distance: 1 },
            { index: '34', distance: 1 },
            { index: '2', distance: 1 }
        ],'index'));
    expect(sortByKey(rows[1].KRING_DISTANCES,'index')).toEqual(
        sortByKey([
            { index: '12070922', distance: 0 },
            { index: '12103722', distance: 1 },
            { index: '12103690', distance: 1 },
            { index: '12103658', distance: 1 },
            { index: '12070954', distance: 1 },
            { index: '12070890', distance: 1 },
            { index: '12038186', distance: 1 },
            { index: '12038154', distance: 1 },
            { index: '12038122', distance: 1 }
        ],'index'));
    expect(sortByKey(rows[2].KRING_DISTANCES,'index')).toEqual(
        sortByKey([
            { index: '12070922', distance: 0 },
            { index: '12103722', distance: 1 },
            { index: '12103690', distance: 1 },
            { index: '12103658', distance: 1 },
            { index: '12070954', distance: 1 },
            { index: '12070890', distance: 1 },
            { index: '12038186', distance: 1 },
            { index: '12038154', distance: 1 },
            { index: '12038122', distance: 1 },
            { index: '12136522', distance: 2 },
            { index: '12136490', distance: 2 },
            { index: '12136458', distance: 2 },
            { index: '12136426', distance: 2 },
            { index: '12136394', distance: 2 },
            { index: '12103754', distance: 2 },
            { index: '12103626', distance: 2 },
            { index: '12070986', distance: 2 },
            { index: '12070858', distance: 2 },
            { index: '12038218', distance: 2 },
            { index: '12038090', distance: 2 },
            { index: '12005450', distance: 2 },
            { index: '12005418', distance: 2 },
            { index: '12005386', distance: 2 },
            { index: '12005354', distance: 2 },
            { index: '12005322', distance: 2 }
        ],'index'));
});

test('KRING_DISTANCES should fail if any invalid argument', async () => {
    let query = 'SELECT @@SF_PREFIX@@quadkey.KRING_DISTANCES(NULL, NULL)';
    await expect(runQuery(query)).rejects.toThrow(/Invalid input origin/);

    query = 'SELECT @@SF_PREFIX@@quadkey.KRING_DISTANCES(-1, 1)';
    await expect(runQuery(query)).rejects.toThrow(/Invalid input origin/);

    query = 'SELECT @@SF_PREFIX@@quadkey.KRING_DISTANCES(162, -1)';
    await expect(runQuery(query)).rejects.toThrow(/Invalid input size/);
});