--------------------------------
-- Copyright (C) 2023-2024 CARTO
--------------------------------

CREATE OR REPLACE PROCEDURE @@SF_SCHEMA@@.H3_POLYFILL_TABLE
(
    input_query STRING,
    resolution INT,
    mode STRING,
    output_table STRING
)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS $$
DECLARE
    column_names_csv STRING;
    column_names_query STRING;
    polyfill_query STRING;
    database_name STRING;
BEGIN

    -- Check valid output table name
    CALL @@SF_SCHEMA@@._CHECK_TABLE(:output_table);

    -- Validate
    EXECUTE IMMEDIATE 'SELECT * FROM (' || input_query || ') WHERE FALSE';

    -- New table with correct columns
    EXECUTE IMMEDIATE 'CREATE OR REPLACE TABLE ' || output_table || ' CLUSTER BY (H3) AS SELECT * EXCLUDE geom, NULL as H3 FROM (' || input_query || ') WHERE FALSE';

    database_name := (SELECT @@SF_SCHEMA@@._GET_DATABASE(:output_table));

    column_names_query := '
        SELECT LISTAGG(COLUMN_NAME, '','')
        FROM ' || database_name || '.INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME ILIKE @@SF_SCHEMA@@._GET_TABLENAME(''' || output_table || ''')
        AND TABLE_CATALOG ILIKE @@SF_SCHEMA@@._GET_DATABASE(''' || output_table || ''')
        AND TABLE_SCHEMA ILIKE @@SF_SCHEMA@@._GET_SCHEMA(''' || output_table || ''')
        AND COLUMN_NAME NOT ILIKE ''geom''
        ';

    EXECUTE IMMEDIATE column_names_query;
    SELECT $1 INTO column_names_csv FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

    polyfill_query := 'INSERT INTO ' || output_table || ' (' || column_names_csv || ') SELECT ' || column_names_csv ||
                            ' FROM (WITH virtual_table AS (' || input_query ||
                            ') SELECT *, value as H3 FROM virtual_table, LATERAL FLATTEN(input => @@SF_SCHEMA@@.H3_POLYFILL(virtual_table.geom, '
                            || resolution || ',\'' || mode || '\')))';

    EXECUTE IMMEDIATE polyfill_query;

    RETURN 'Finished!';
END;
$$;
