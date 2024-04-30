---------------------------
-- Copyright (C) 2024 CARTO
---------------------------

CREATE OR REPLACE PROCEDURE @@SF_SCHEMA@@._CHECK_TABLE
(TABLE_IDENTIFIER STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS $$
DECLARE
	parts_count INT;
BEGIN
	parts_count := (
		SELECT ARRAY_SIZE(SPLIT(table_identifier, '.'))
		FROM (SELECT :TABLE_IDENTIFIER AS table_identifier)
	);

	IF (parts_count != 3) THEN
		SELECT @@SF_SCHEMA@@._CARTO_ERROR('Invalid table name: ' || :TABLE_IDENTIFIER);
	END IF;
END;
$$;
