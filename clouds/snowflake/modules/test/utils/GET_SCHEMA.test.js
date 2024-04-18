const { runQuery } = require('../../../common/test-utils');

describe('_GET_SCHEMA should detect the correct SCHEMA from table identifier', () => {

    test('when the identifier is in the format: <database>.<schema>.<table>', async () => {
        let rows = await runQuery("SELECT _GET_SCHEMA('databasename.schemaname.tablename') AS result");
        expect(rows[0].RESULT).toEqual('schemaname')
    })

    test('when the identifier is in the format: <schema>.<table>', async () => {
        let rows = await runQuery("SELECT _GET_SCHEMA('schemaname.tablename') AS result");
        expect(rows[0].RESULT).toEqual('schemaname')
    })

    test('when the identifier is in the format: <table>', async () => {
        let rows = await runQuery('SELECT CURRENT_SCHEMA() AS CURRENT_SCHEMA');
        expected_schema = rows[0].CURRENT_SCHEMA
        rows = await runQuery("SELECT _GET_SCHEMA('tablename') AS result");
        expect(rows[0].RESULT).toEqual(expected_schema)
    })

})