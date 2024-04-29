---------------------------
-- Copyright (C) 2023 CARTO
---------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._GET_SCHEMA
(table_identifier STRING)
RETURNS STRING
LANGUAGE SQL
IMMUTABLE
AS $$
	SELECT SPLIT_PART(table_identifier, '.', -1)
	FROM (SELECT TABLE_IDENTIFIER AS table_identifier)
$$;
