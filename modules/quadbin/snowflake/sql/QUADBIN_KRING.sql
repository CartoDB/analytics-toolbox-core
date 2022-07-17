----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_KRING
(origin BIGINT, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$   
    TO_ARRAY(PARSE_JSON(_QUADBIN_KRING(TO_VARCHAR(ORIGIN, 'xxxxxxxxxxxxxxxx'), SIZE, false)))
$$;