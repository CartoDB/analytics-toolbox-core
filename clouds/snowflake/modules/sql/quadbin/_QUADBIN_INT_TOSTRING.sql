----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_INT_TOSTRING
(quadbin BIGINT)
RETURNS STRING
IMMUTABLE
AS $$
    TO_VARCHAR(quadbin, 'xxxxxxxxxxxxxxxx')
$$;