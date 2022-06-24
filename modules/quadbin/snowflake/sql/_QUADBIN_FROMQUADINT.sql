----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADBIN_FROMQUADINT
(quadint INT)
RETURNS BIGINT
AS $$
    WITH
    __zxy AS (
        SELECT QUADINT_TOZXY(quadint) as tile
    )
    SELECT QUADBIN_FROMZXY(tile:z, tile:x, tile:y)
    FROM __zxy
$$;