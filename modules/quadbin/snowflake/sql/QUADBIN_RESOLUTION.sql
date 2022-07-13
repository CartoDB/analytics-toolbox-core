----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_RESOLUTION
(quadbin BIGINT)
RETURNS INT
IMMUTABLE
AS $$
    SELECT BITAND(BITSHIFTRIGHT(quadbin, 52), 31)
$$;