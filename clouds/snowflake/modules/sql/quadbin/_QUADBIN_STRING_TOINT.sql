----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_STRING_TOINT
(quadbin STRING)
RETURNS BIGINT
IMMUTABLE
AS $$
    TO_NUMBER(quadbin, 'XXXXXXXXXXXXXXXX')
$$;