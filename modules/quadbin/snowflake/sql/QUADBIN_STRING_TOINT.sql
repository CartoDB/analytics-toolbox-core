----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_STRING_TOINT
(quadbin STRING)
RETURNS INT
AS $$
    TO_NUMBER(quadbin, 'XXXXXXXXXXXXXXXX')
$$;