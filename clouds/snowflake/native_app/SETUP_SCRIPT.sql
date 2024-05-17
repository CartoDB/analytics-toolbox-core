CREATE OR REPLACE PROCEDURE @@SF_SCHEMA@@.GET_MODULES_SQL_FROM_STAGE()
    returns string
    language python
    runtime_version = '3.8'
    packages = ('snowflake-snowpark-python')
    imports = (
        '/get_modules_sql_from_stage.py',
        '/modules.sql'
    )
    handler = 'get_modules_sql_from_stage.main'
    ;

GRANT USAGE ON PROCEDURE @@SF_SCHEMA@@.GET_MODULES_SQL_FROM_STAGE() TO APPLICATION ROLE @@APP_ROLE@@;

CREATE OR REPLACE PROCEDURE @@SF_SCHEMA@@.GENERATE_INSTALLER(destination_schema STRING)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS $$
  const QUOTE = '$' + '$'
  const functions = [`
    CREATE OR REPLACE PROCEDURE ${DESTINATION_SCHEMA}.INSTALL(source_app STRING, destination_schema STRING)
    RETURNS VARCHAR
    LANGUAGE JAVASCRIPT
    EXECUTE AS OWNER
    AS ${QUOTE}
        const QUOTE = '$' + '$';
        const rs = snowflake.execute({ sqlText: 'CALL ' + SOURCE_APP + '.GET_MODULES_SQL_FROM_STAGE()'});
        rs.next();
        let modulesSql = rs.getColumnValue(1);
        let resultMessage = 'Procedure installed';
        
        const replacements = [
            ['@@SF_SCHEMA@@', DESTINATION_SCHEMA]
        ]

        for (const [variable, value] of replacements) {
        modulesSql = modulesSql.replaceAll(variable, value);
        }
        snowflake.execute({ sqlText: modulesSql });

    ${QUOTE};
    `]
  let resultMessage = 'Procedure installed';

  for (let modulesSql of functions) {
    snowflake.execute({ sqlText: modulesSql });
  }
$$;

GRANT USAGE ON PROCEDURE @@SF_SCHEMA@@.GENERATE_INSTALLER(STRING) TO APPLICATION ROLE @@APP_ROLE@@;
