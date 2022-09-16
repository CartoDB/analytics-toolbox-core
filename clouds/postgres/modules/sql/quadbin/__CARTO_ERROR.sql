----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE or REPLACE FUNCTION @@PG_SCHEMA@@.__CARTO_ERROR(
    message TEXT
)
RETURNS TEXT
AS
$BODY$
BEGIN
    RAISE EXCEPTION 'CARTO Error: %', message;
END;
$BODY$
LANGUAGE PLPGSQL;
