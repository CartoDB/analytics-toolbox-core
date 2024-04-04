--------------------------------
-- Copyright (C) 2023-2024 CARTO
--------------------------------

-- TODO: CLUSTER
-- TODO: disallow query column names which conflict with FLATTEN columns
-- TODO: SCHEMA
-- TODO: TESTS

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
    polyfill_query STRING;
BEGIN

    -- Validate
    EXECUTE IMMEDIATE 'SELECT * FROM (' || input_query || ') WHERE FALSE';

    -- New table with correct columns
    EXECUTE IMMEDIATE 'CREATE TABLE ' || output_table || ' AS SELECT * EXCLUDE geom, NULL as H3 FROM (' || input_query || ') WHERE FALSE';

    column_names_csv := (SELECT LISTAGG(COLUMN_NAME, ',') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ILIKE :output_table AND TABLE_SCHEMA=CURRENT_SCHEMA());

    polyfill_query := 'INSERT INTO ' || output_table || ' (' || column_names_csv || ') SELECT ' || column_names_csv || ' FROM (WITH virtual_table AS (' || input_query || ') SELECT *, value as H3 FROM virtual_table, LATERAL FLATTEN(input => H3_POLYFILL(virtual_table.geom, ' || resolution || ',\'' || mode || '\')))';

    EXECUTE IMMEDIATE polyfill_query;

    RETURN 'Finished!';
END;
$$;
