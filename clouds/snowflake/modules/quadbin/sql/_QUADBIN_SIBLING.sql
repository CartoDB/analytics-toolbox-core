----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_SIBLING
(origin INT, dx INT, dy INT)
RETURNS INT
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._ZXY_QUADBIN_SIBLING(
        @@SF_SCHEMA@@._QUADBIN_TOZXY(TO_VARCHAR(ORIGIN, 'xxxxxxxxxxxxxxxx')), DX, DY
    )
$$;