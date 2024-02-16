const { runQuery, deleteTable, deleteView } = require('../../../common/test-utils');

test('QUADBIN_TOPARENT should work', async () => {
    const query = 'SELECT CAST(QUADBIN_TOPARENT(5209574053332910079, 3) AS STRING) AS OUTPUT';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual('5205105638077628415');
});

test('QUADBIN_TOPARENT should work with nested functions when readin data from views', async () => {
    const inputTable = '@@SF_SCHEMA@@.coords_sample';
    const inputTableView = '@@SF_SCHEMA@@.test_quadbin_toparent_view';

    query = `CREATE VIEW IF NOT EXISTS ${inputTableView} AS
        SELECT * FROM ${inputTable};`;
    await runQuery(query);

    query = `SELECT CAST(QUADBIN_TOPARENT(QUADBIN_FROMLONGLAT(long, lat, zoom), 6) AS STRING) AS OUTPUT
        FROM ${inputTableView};`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(120);

    deleteView(inputTableView);
});