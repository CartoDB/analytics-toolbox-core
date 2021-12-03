CREATE OR REPLACE PROCEDURE _DROP_FUNCTIONS()
RETURNS VARCHAR
LANGUAGE javascript
IMMUTABLE
AS $$
    let rs = snowflake.execute({
        sqlText: 'SHOW USER FUNCTIONS IN SCHEMA @@SF_DATABASE@@.@@SF_SCHEMA@@;'
    });
    let cmd1_dict = {
      sqlText: `
        SELECT CONCAT(
            'DROP FUNCTION ',
            "catalog_name",
            '.',
            "schema_name",
            '.',
            REGEXP_REPLACE("arguments", ' RETURN .*$', ''),
            ';'
        ) AS drop_command
        FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));`
    };
    let stmt = snowflake.createStatement(cmd1_dict);
    rs = stmt.execute();
    let s = '';
    let CONTINUEONERROR = false; // Default to false for overloaded function
    while (rs && rs.next()) {
        try {
            cmd2_dict = { sqlText: rs.getColumnValue('DROP_COMMAND') };
            stmtEx = snowflake.createStatement(cmd2_dict);
            stmtEx.execute();
            s += rs.getColumnValue(1) + ' --Succeeded' + '\n';
        }
        catch (err) {
            s += rs.getColumnValue(1) + ' --Failed: ' + err.message.replace(/\n/g, ' ') + '\n';
            if (!CONTINUEONERROR) return s;
        }
    }
    if (s) return s;
$$;

CREATE OR REPLACE PROCEDURE _DROP_PROCEDURES()
RETURNS VARCHAR
LANGUAGE javascript
IMMUTABLE
AS $$
    let rs = snowflake.execute({
        sqlText: 'SHOW USER PROCEDURES IN SCHEMA @@SF_DATABASE@@.@@SF_SCHEMA@@;'
    });
    let cmd1_dict = {
      sqlText: `
        SELECT CONCAT(
            'DROP PROCEDURE ',
            "catalog_name",
            '.',
            "schema_name",
            '.',
            REGEXP_REPLACE("arguments", ' RETURN .*$', ''),
            ';'
        ) AS drop_command
        FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));`
    };
    let stmt = snowflake.createStatement(cmd1_dict);
    rs = stmt.execute();
    let s = '';
    let CONTINUEONERROR = false; // Default to false for overloaded function
    while (rs && rs.next()) {
        try {
            cmd2_dict = { sqlText: rs.getColumnValue('DROP_COMMAND') };
            stmtEx = snowflake.createStatement(cmd2_dict);
            stmtEx.execute();
            s += rs.getColumnValue(1) + ' --Succeeded' + '\n';
        }
        catch (err) {
            s += rs.getColumnValue(1) + ' --Failed: ' + err.message.replace(/\n/g, ' ') + '\n';
            if (!CONTINUEONERROR) return s;
        }
    }
    if (s) return s;
$$;

CALL _DROP_FUNCTIONS();
CALL _DROP_PROCEDURES();
