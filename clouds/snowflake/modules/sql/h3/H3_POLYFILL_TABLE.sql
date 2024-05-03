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
BEGIN
    EXECUTE IMMEDIATE '
        CREATE OR REPLACE TABLE ' || output_table || ' CLUSTER BY (H3) AS
        WITH __input AS ( ' || input_query || ' )
        SELECT CAST(cell.value AS STRING) AS h3, i.* EXCLUDE(geom)
        FROM __input AS i, TABLE(FLATTEN(@@SF_SCHEMA@@.H3_POLYFILL(geom, ' || resolution || ', ''' || mode || '''))) AS cell;
    ';

    RETURN 'H3 Polyfill result added in table ' || output_table;
END;
$$;
