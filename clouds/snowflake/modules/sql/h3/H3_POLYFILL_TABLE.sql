--------------------------------
-- Copyright (C) 2023-2024 CARTO
--------------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._GET_SCHEMA
(table_identifier STRING)
RETURNS STRING
LANGUAGE SQL
IMMUTABLE
AS $$
	WITH split_identifier AS (
		SELECT ARRAY_SIZE(SPLIT(table_identifier, '.')) AS parts_count,
		SPLIT_PART(table_identifier, '.', 1) AS first_part,
		SPLIT_PART(table_identifier, '.', 2) AS second_part
		FROM (SELECT TABLE_IDENTIFIER AS table_identifier)
	)
	SELECT
		CASE parts_count
			WHEN 3 THEN second_part
			WHEN 2 THEN first_part
			ELSE CURRENT_SCHEMA()
		END
	FROM split_identifier
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._GET_DATABASE
(table_identifier STRING)
RETURNS STRING
LANGUAGE SQL
IMMUTABLE
AS $$
	WITH split_identifier AS (
		SELECT ARRAY_SIZE(SPLIT(table_identifier, '.')) AS parts_count,
		SPLIT_PART(table_identifier, '.', 1) AS first_part
		FROM (SELECT TABLE_IDENTIFIER AS table_identifier)
	)
	SELECT
		CASE parts_count
			WHEN 3 THEN first_part
			ELSE CURRENT_DATABASE()
		END
	FROM split_identifier
$$;

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
    EXECUTE IMMEDIATE 'CREATE OR REPLACE TABLE ' || output_table || ' CLUSTER BY (H3) AS SELECT * EXCLUDE geom, NULL as H3 FROM (' || input_query || ') WHERE FALSE';

    column_names_csv := (SELECT LISTAGG(COLUMN_NAME, ',') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ILIKE :output_table AND TABLE_CATALOG=@@SF_SCHEMA@@._GET_DATABASE(:output_table) AND TABLE_SCHEMA=@@SF_SCHEMA@@._GET_SCHEMA(:output_table));

    polyfill_query := 'INSERT INTO ' || output_table || ' (' || column_names_csv || ') SELECT ' || column_names_csv || ' FROM (WITH virtual_table AS (' || input_query || ') SELECT *, value as H3 FROM virtual_table, LATERAL FLATTEN(input => @@SF_SCHEMA@@.H3_POLYFILL(virtual_table.geom, ' || resolution || ',\'' || mode || '\')))';

    EXECUTE IMMEDIATE polyfill_query;

    RETURN 'Finished!';
END;
$$;
