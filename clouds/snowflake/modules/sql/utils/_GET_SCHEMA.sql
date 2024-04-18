---------------------------
-- Copyright (C) 2023 CARTO
---------------------------

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
