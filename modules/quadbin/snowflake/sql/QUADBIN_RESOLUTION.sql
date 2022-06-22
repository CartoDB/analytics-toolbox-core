----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_RESOLUTION
(quadbin INT)
RETURNS INT
AS $$
    SELECT BITSHIFTRIGHT(quadbin, 58)
$$;