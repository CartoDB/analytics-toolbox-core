CREATE OR REPLACE PROCEDURE @@SF_PREFIX@@carto._DROP_FUNCTIONS()
  RETURNS VARCHAR
  LANGUAGE javascript
  IMMUTABLE
  AS
  $$
  var rs = snowflake.execute( { sqlText: 
      `show user functions in schema @@SF_PREFIX@@carto;`
       } );
      cmd1_dict = {sqlText: `SELECT
      CONCAT(
      'DROP FUNCTION ',
      "catalog_name",
      '.',
      "schema_name",
      '.',
      REGEXP_REPLACE("arguments", ' RETURN .*$', ''),
      ';'
    ) AS drop_command
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));`};
      stmt = snowflake.createStatement(cmd1_dict);
      rs = stmt.execute();
      var s = '';
      var CONTINUEONERROR = false; // Default to false for overloaded function
      while (rs.next()) {
          try{
                cmd2_dict = {sqlText: rs.getColumnValue("DROP_COMMAND")};
                stmtEx = snowflake.createStatement(cmd2_dict);
                stmtEx.execute();
                s += rs.getColumnValue(1) + " --Succeeded" + "\n";
             }
          catch(err) {
                s += rs.getColumnValue(1) + " --Failed: " + err.message.replace(/\n/g, " ") + "\n";
                if (!CONTINUEONERROR) return s;
          }
      }
      return s;
  $$;

CREATE OR REPLACE PROCEDURE @@SF_PREFIX@@carto._DROP_PROCEDURES()
  RETURNS VARCHAR
  LANGUAGE javascript
  IMMUTABLE
  AS
  $$
  var rs = snowflake.execute( { sqlText: 
      `show user procedures in schema @@SF_PREFIX@@carto;`
       } );
      cmd1_dict = {sqlText: `SELECT
      CONCAT(
      'DROP PROCEDURE ',
      "catalog_name",
      '.',
      "schema_name",
      '.',
      REGEXP_REPLACE("arguments", ' RETURN .*$', ''),
      ';'
    ) AS drop_command
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));`};
      stmt = snowflake.createStatement(cmd1_dict);
      rs = stmt.execute();
      var s = '';
      var CONTINUEONERROR = false; // Default to false for overloaded function
      while (rs.next()) {
          try{
                cmd2_dict = {sqlText: rs.getColumnValue("DROP_COMMAND")};
                stmtEx = snowflake.createStatement(cmd2_dict);
                stmtEx.execute();
                s += rs.getColumnValue(1) + " --Succeeded" + "\n";
             }
          catch(err) {
                s += rs.getColumnValue(1) + " --Failed: " + err.message.replace(/\n/g, " ") + "\n";
                if (!CONTINUEONERROR) return s;
          }
      }
      return s;
  $$;

CALL @@SF_PREFIX@@carto._DROP_FUNCTIONS();
CALL @@SF_PREFIX@@carto._DROP_PROCEDURES();             