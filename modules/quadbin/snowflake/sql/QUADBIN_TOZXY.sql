----------------------------
-- Copyright (C) 2022 CARTO
----------------------------


CREATE OR REPLACE SECURE FUNCTION QUADBIN_TOZXY
(quadbin BIGINT)
RETURNS OBJECT
IMMUTABLE
AS $$
    _QUADBIN_TOZXY(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx'))
$$;
