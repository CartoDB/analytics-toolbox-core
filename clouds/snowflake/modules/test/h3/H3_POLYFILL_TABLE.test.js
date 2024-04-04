const { runQuery } = require('../../../common/test-utils');

test('_GET_SCHEMA should detect the correct SCHEMA from table identifier', async () => {
	
    let rows = await runQuery("SELECT _GET_SCHEMA('databasename.schemaname.tablename') AS result");
    expect(rows[0].RESULT).toEqual('schemaname')

    rows = await runQuery("SELECT _GET_SCHEMA('schemaname.tablename') AS result");
    expect(rows[0].RESULT).toEqual('schemaname')

    rows = await runQuery('SELECT CURRENT_SCHEMA() AS CURRENT_SCHEMA');
    expected_schema = rows[0].CURRENT_SCHEMA
    rows = await runQuery("SELECT _GET_SCHEMA('tablename') AS result");
    expect(rows[0].RESULT).toEqual(expected_schema)
})

test('_GET_DATABASE should detect the correct DATABASE from table identifier', async () => {
	
    let rows = await runQuery("SELECT _GET_DATABASE('databasename.schemaname.tablename') AS result");
    expect(rows[0].RESULT).toEqual('databasename')

    rows = await runQuery('SELECT CURRENT_DATABASE() AS CURRENT_DATABASE');
    expected_db = rows[0].CURRENT_DATABASE
    rows = await runQuery("SELECT _GET_DATABASE('schemaname.tablename') AS result");
    expect(rows[0].RESULT).toEqual(expected_db)

    rows = await runQuery("SELECT _GET_DATABASE('tablename') AS result");
    expect(rows[0].RESULT).toEqual(expected_db)
})