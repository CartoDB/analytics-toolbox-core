----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADBIN_SIBLING
(origin INT, dx INT, dy INT)
RETURNS INT
IMMUTABLE
AS $$
    _ZXY_QUADBIN_SIBLING(
        _QUADBIN_TOZXY(TO_VARCHAR(ORIGIN, 'xxxxxxxxxxxxxxxx')), DX, DY
    )
$$;