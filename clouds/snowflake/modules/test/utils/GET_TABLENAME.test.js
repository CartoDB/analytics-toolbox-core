const { runQuery } = require('../../../common/test-utils');

describe('_GET_TABLENAME should detect the correct TABLENAME from table identifier', () => {
    test('when the identifier is in the format: <database>.<schema>.<table>', async () => {
        let rows = await runQuery(
            "SELECT _GET_TABLENAME('databasename.schemaname.tablename') AS result"
        );
        expect(rows[0].RESULT).toEqual('tablename');
    });

    test('when the identifier is in the format: <schema>.<table>', async () => {
        let rows = await runQuery(
            "SELECT _GET_TABLENAME('schemaname.tablename') AS result"
        );
        expect(rows[0].RESULT).toEqual('tablename');
    });

    test('when the identifier is in the format: <table>', async () => {
        rows = await runQuery("SELECT _GET_TABLENAME('tablename') AS result");
        expect(rows[0].RESULT).toEqual('tablename');
    });
});
