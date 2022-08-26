----------------------------
-- Copyright (C) 2022 CARTO
----------------------------


CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_TOZXY
(quadbin BIGINT)
RETURNS OBJECT
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._QUADBIN_TOZXY(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx'))
$$;
