---------------------------
-- Copyright (C) 2024 CARTO
---------------------------

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
