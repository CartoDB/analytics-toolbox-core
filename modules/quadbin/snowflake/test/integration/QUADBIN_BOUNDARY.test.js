const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADBIN_BOUNDARY should work', async () => {
    const query = 'SELECT QUADBIN_BOUNDARY(5209574053332910079) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual({"coordinates": [[[22.5, 0], [22.5, -21.94304553343817], [45, -21.94304553343817], [45, 0], [22.5, 0]]], "type": "Polygon"});
});