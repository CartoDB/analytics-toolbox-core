----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADBIN_STRING_TOINT
(quadbin STRING)
RETURNS BIGINT
AS $$
    TO_NUMBER(quadbin, 'XXXXXXXXXXXXXXXX')
$$;