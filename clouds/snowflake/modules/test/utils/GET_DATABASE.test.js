const { runQuery } = require('../../../common/test-utils');

describe('_GET_DATABASE should detect the correct DATABASE from table identifier', () => {

    test('when the identifier is in the format: <database>.<schema>.<table>', async () => {
        let rows = await runQuery("SELECT _GET_DATABASE('databasename.schemaname.tablename') AS result");
        expect(rows[0].RESULT).toEqual('databasename')
    })

    test('when the identifier is in the format: <schema>.<table>', async () => {
        let rows = await runQuery('SELECT CURRENT_DATABASE() AS CURRENT_DATABASE');
        expected_db = rows[0].CURRENT_DATABASE
        rows = await runQuery("SELECT _GET_DATABASE('schemaname.tablename') AS result");
        expect(rows[0].RESULT).toEqual(expected_db)
    })

    test('when the identifier is in the format: <table>', async () => {
        let rows = await runQuery('SELECT CURRENT_DATABASE() AS CURRENT_DATABASE');
        expected_db = rows[0].CURRENT_DATABASE
        rows = await runQuery("SELECT _GET_DATABASE('tablename') AS result");
        expect(rows[0].RESULT).toEqual(expected_db)
    })

})