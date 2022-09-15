const { runQuery } = require('../../../common/test-utils');

test('S2_CENTER should work', async () => {
    const query = 'SELECT ST_ASTEXT(`@@BQ_DATASET@@.S2_CENTER`(1735346007979327488)) as id';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].id.toString()).toEqual('POINT(40.4720004343497 -3.72646193231851)');
});