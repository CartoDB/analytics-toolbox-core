const { runQuery, sortByKey } = require('../../../../../common/bigquery/test-utils');

test('Works as expected with invalid data', async () => {
    const query = `
        WITH ids AS
        (
            -- Invalid parameters
            SELECT 1 AS id, NULL as origin, 1 as size UNION ALL
            SELECT 2 AS id, 'ff283473fffffff' as origin, 1 as size UNION ALL
            SELECT 3 as id, '8928308280fffff' as origin, -1 as size UNION ALL

            -- Size 0
            SELECT 4 as id, '8928308280fffff' as origin, 0 as size
        )
        SELECT
            id,
            \`@@BQ_PREFIX@@h3.KRING_DISTANCES\`(origin, size) as parent
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(4);
    expect(rows[0].parent).toEqual([]);
    expect(rows[1].parent).toEqual([]);
    expect(rows[2].parent).toEqual([]);
    expect(rows[3].parent).toEqual([{ index: '8928308280fffff', distance: 0 }]);
});

test('List the ring correctly', async () => {
    const query = `
        WITH ids AS
        (
            SELECT '8928308280fffff' as origin
        )
        SELECT
            \`@@BQ_PREFIX@@h3.KRING_DISTANCES\`(origin, 1) as d1,
            \`@@BQ_PREFIX@@h3.KRING_DISTANCES\`(origin, 2) as d2
        FROM ids
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    /* Data comes from h3core.spec.js */
    expect(sortByKey(rows[0].d1,'index')).toEqual(
        sortByKey([
            { index: '8928308280fffff', distance: 0 },
            { index: '8928308280bffff', distance: 1 },
            { index: '89283082807ffff', distance: 1 },
            { index: '89283082877ffff', distance: 1 },
            { index: '89283082803ffff', distance: 1 },
            { index: '89283082873ffff', distance: 1 },
            { index: '8928308283bffff', distance: 1 }
        ],'index'));
    expect(sortByKey(rows[0].d2,'index')).toEqual(
        sortByKey([   
            { index: '8928308280fffff', distance: 0 },
            { index: '8928308280bffff', distance: 1 },
            { index: '89283082873ffff', distance: 1 },
            { index: '89283082877ffff', distance: 1 },
            { index: '8928308283bffff', distance: 1 },
            { index: '89283082807ffff', distance: 1 },
            { index: '89283082803ffff', distance: 1 },
            { index: '8928308281bffff', distance: 2 },
            { index: '89283082857ffff', distance: 2 },
            { index: '89283082847ffff', distance: 2 },
            { index: '8928308287bffff', distance: 2 },
            { index: '89283082863ffff', distance: 2 },
            { index: '89283082867ffff', distance: 2 },
            { index: '8928308282bffff', distance: 2 },
            { index: '89283082823ffff', distance: 2 },
            { index: '89283082833ffff', distance: 2 },
            { index: '892830828abffff', distance: 2 },
            { index: '89283082817ffff', distance: 2 },
            { index: '89283082813ffff', distance: 2 }
        ],'index'));
});

test('Zero size returns self', async () => {
    const query = `
        WITH ids AS
        (
            SELECT '87283080dffffff' as origin
        )
        SELECT
            \`@@BQ_PREFIX@@h3.KRING_DISTANCES\`(origin, 0) AS self_children
        FROM ids
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].self_children).toEqual([{ index: '87283080dffffff', distance: 0 }]);
});