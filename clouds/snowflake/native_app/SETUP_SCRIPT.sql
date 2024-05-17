CREATE OR REPLACE PROCEDURE @@SF_SCHEMA@@.GENERATE_INSTALL_AT_PROC(destination_schema STRING)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS $$
  const QUOTE = '$' + '$'
  const functions = [`
    CREATE OR REPLACE PROCEDURE ${DESTINATION_SCHEMA}.INSTALL_AT(source_app STRING, destination_schema STRING)
    RETURNS VARCHAR
    LANGUAGE JAVASCRIPT
    EXECUTE AS OWNER
    AS ${QUOTE}
        const QUOTE = '$' + '$';
        const rs = snowflake.execute({ sqlText: 'CALL ' + SOURCE_APP + '.install_js_script_from_stagedfile()'});
        rs.next();
        let functionSql = rs.getColumnValue(1);
        let resultMessage = 'Procedure installed';
        
        const replacements = [
            ['@@SF_SCHEMA@@', DESTINATION_SCHEMA]
        ]

        for (const [variable, value] of replacements) {
        functionSql = functionSql.replaceAll(variable, value);
        }
        snowflake.execute({ sqlText: functionSql });

    ${QUOTE};
    `]
  let resultMessage = 'Procedure installed';

  for (let functionSql of functions) {
    snowflake.execute({ sqlText: functionSql });
  }
$$;

CREATE OR REPLACE PROCEDURE @@SF_SCHEMA@@.CREATE OR REPLACE PROCEDURE @@SF_SCHEMA@@.GENERATE_INSTALL_AT_PROC(destination_schema STRING)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS $$
  const QUOTE = '$' + '$'
  const functions = [`
    CREATE OR REPLACE PROCEDURE ${DESTINATION_SCHEMA}.INSTALL_AT(source_app STRING, destination_schema STRING)
    RETURNS VARCHAR
    LANGUAGE JAVASCRIPT
    EXECUTE AS OWNER
    AS ${QUOTE}
        const QUOTE = '$' + '$';
        const rs = snowflake.execute({ sqlText: 'CALL ' + SOURCE_APP + '.install_js_script_from_stagedfile()'});
        rs.next();
        let functionSql = rs.getColumnValue(1);
        let resultMessage = 'Procedure installed';
        
        const replacements = [
            ['@@SF_SCHEMA@@', DESTINATION_SCHEMA]
        ]

        for (const [variable, value] of replacements) {
        functionSql = functionSql.replaceAll(variable, value);
        }
        snowflake.execute({ sqlText: functionSql });

    ${QUOTE};
    `]
  let resultMessage = 'Procedure installed';

  for (let functionSql of functions) {
    snowflake.execute({ sqlText: functionSql });
  }
$$;

GRANT USAGE ON PROCEDURE @@SF_SCHEMA@@.GENERATE_INSTALL_AT_PROC(STRING) TO APPLICATION ROLE @@APP_ROLE@@;

CREATE OR REPLACE PROCEDURE @@SF_SCHEMA@@.INSTALL_JS_SCRIPT_FROM_STAGEDFILE()
    returns string
    language python
    runtime_version = '3.8'
    packages = ('snowflake-snowpark-python')
    imports = (
        '/install_scripts_from_stage.py',
        '/modules.sql'
    )
    handler = 'install_scripts_from_stage.main'
    ;
()
    returns string
    language python
    runtime_version = '3.8'
    packages = ('snowflake-snowpark-python')
    imports = (
        '/install_scripts_from_stage.py',
        '/modules.sql'
    )
    handler = 'install_scripts_from_stage.main'
    ;

GRANT USAGE ON PROCEDURE @@SF_SCHEMA@@.install_js_script_from_stagedfile() TO APPLICATION ROLE @@APP_ROLE@@;