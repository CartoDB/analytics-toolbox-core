const { runQuery, sortByKey } = require('../../../../../common/snowflake/test-utils');

test('KRING_DISTANCES should work', async () => {
    const query = `
        SELECT @@SF_PREFIX@@h3.KRING_DISTANCES('8928308280fffff', 0) as d0,
               @@SF_PREFIX@@h3.KRING_DISTANCES('8928308280fffff', 1) as d1,
               @@SF_PREFIX@@h3.KRING_DISTANCES('8928308280fffff', 2) as d2
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(sortByKey(rows[0].D0,'index')).toEqual(sortByKey([
        { index: '8928308280fffff', distance: 0 }
    ],'index'));
    expect(sortByKey(rows[0].D1,'index')).toEqual(sortByKey([
        { index: '8928308280fffff', distance: 0 },
        { index: '8928308280bffff', distance: 1 },
        { index: '89283082807ffff', distance: 1 },
        { index: '89283082877ffff', distance: 1 },
        { index: '89283082803ffff', distance: 1 },
        { index: '89283082873ffff', distance: 1 },
        { index: '8928308283bffff', distance: 1 }
    ],'index'));
    expect(sortByKey(rows[0].D2,'index')).toEqual(sortByKey([
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

test('KRING_DISTANCES should fail if any invalid argument', async () => {
    let query = 'SELECT @@SF_PREFIX@@h3.KRING_DISTANCES(NULL, NULL)';
    await expect(runQuery(query)).rejects.toThrow(/Invalid input origin/);

    query = 'SELECT @@SF_PREFIX@@h3.KRING_DISTANCES(\'abc\', 1)';
    await expect(runQuery(query)).rejects.toThrow(/Invalid input origin/);

    query = 'SELECT @@SF_PREFIX@@h3.KRING_DISTANCES(\'8928308280fffff\', -1)';
    await expect(runQuery(query)).rejects.toThrow(/Invalid input size/);
});