const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('H3_KRING should work', async () => {
    const query = `
        SELECT H3_KRING('8928308280fffff', 0) as d0,
               H3_KRING('8928308280fffff', 1) as d1,
               H3_KRING('8928308280fffff', 2) as d2
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].D0.sort()).toEqual([
        '8928308280fffff'
    ].sort());
    expect(rows[0].D1.sort()).toEqual([
        '8928308280fffff',
        '8928308280bffff',
        '89283082807ffff',
        '89283082877ffff',
        '89283082803ffff',
        '89283082873ffff',
        '8928308283bffff'
    ].sort());
    expect(rows[0].D2.sort()).toEqual([
        '89283082813ffff',
        '89283082817ffff',
        '8928308281bffff',
        '89283082863ffff',
        '89283082823ffff',
        '89283082873ffff',
        '89283082877ffff',
        '8928308287bffff',
        '89283082833ffff',
        '8928308282bffff',
        '8928308283bffff',
        '89283082857ffff',
        '892830828abffff',
        '89283082847ffff',
        '89283082867ffff',
        '89283082803ffff',
        '89283082807ffff',
        '8928308280bffff',
        '8928308280fffff'
    ].sort());
});

test('H3_KRING should fail if any invalid argument', async () => {
    let query = 'SELECT H3_KRING(NULL, NULL)';
    await expect(runQuery(query)).rejects.toThrow(/Invalid input size/);

    query = 'SELECT H3_KRING(\'abc\', 1)';
    await expect(runQuery(query)).rejects.toThrow(/Invalid input origin/);

    query = 'SELECT H3_KRING(\'8928308280fffff\', -1)';
    await expect(runQuery(query)).rejects.toThrow(/Invalid input size/);
});