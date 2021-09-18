const { runQuery } = require('../../../../../common/snowflake/test-utils');

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
            @@SF_PREFIX@@h3.HEXRING(origin, size) as parent
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(4);
    expect(rows[0].PARENT).toEqual([]);
    expect(rows[1].PARENT).toEqual([]);
    expect(rows[2].PARENT).toEqual([]);
    expect(rows[3].PARENT).toEqual(['8928308280fffff']);
});

test('List the ring correctly', async () => {
    const query = `
        WITH ids AS
        (
            SELECT '8928308280fffff' as origin
        )
        SELECT
            @@SF_PREFIX@@h3.HEXRING(origin, 1) as d1,
            @@SF_PREFIX@@h3.HEXRING(origin, 2) as d2
        FROM ids
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    /* Data comes from h3core.spec.js */
    expect(rows[0].D1.sort()).toEqual(
        [   '8928308280bffff',
            '89283082807ffff',
            '89283082877ffff',
            '89283082803ffff',
            '89283082873ffff',
            '8928308283bffff'
        ].sort());
    expect(rows[0].D2.sort()).toEqual(
        [   '89283082813ffff',
            '89283082817ffff',
            '8928308281bffff',
            '89283082863ffff',
            '89283082823ffff',
            '8928308287bffff',
            '89283082833ffff',
            '8928308282bffff',
            '89283082857ffff',
            '892830828abffff',
            '89283082847ffff',
            '89283082867ffff'
        ].sort());
});

test('Zero size returns self', async () => {
    const query = `
        WITH ids AS
        (
            SELECT '87283080dffffff' as origin
        )
        SELECT
            @@SF_PREFIX@@h3.HEXRING(origin, 0) AS self_children
        FROM ids
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].SELF_CHILDREN).toEqual([ '87283080dffffff' ]);
});