const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('S2_BOUNDARY should work', async () => {
    const query = 'SELECT S2_BOUNDARY(3209632993970749440) as boundary';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].BOUNDARY)).toEqual('{"coordinates":[[[124.99991607494462,-14.000016145055083],[124.99991607494462,-13.99970528488021],[125.0002604046465,-13.999648690569117],[125.0002604046465,-13.999959549588995],[124.99991607494462,-14.000016145055083]]],"type":"Polygon"}');
});

test('S2_BOUNDARY should fail with NULL argument', async () => {
    const query = 'SELECT S2_BOUNDARY(null)';
    await expect(runQuery(query)).rejects.toThrow();
});