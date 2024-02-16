const { runQuery, deleteTable } = require('../../../common/test-utils');

test('ST_GENERATEPOINTS should work', async () => {
    const table = 'input_geom_table';
    let query = `CREATE OR REPLACE TABLE ${table} AS
        SELECT TO_GEOGRAPHY('POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))') geog, 10 AS npoints;`
    await runQuery(query);
    query = `SELECT
        @@SF_SCHEMA@@.ST_GENERATEPOINTS(geog, npoints) AS random
        FROM @@SF_SCHEMA@@.${table}
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].RANDOM.length).toEqual(10);

    deleteTable(table);
});