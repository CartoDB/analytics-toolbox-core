const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('_QUADBIN_BOUNDARY should work', async () => {
    const query = 'SELECT _QUADBIN_BOUNDARY(5209574053332910079) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual({ 'coordinates':[[[45,0],[45,-21.943045533],[22.5,-21.943045533],[22.5,0],[45,0]]],'type':'Polygon' });
});