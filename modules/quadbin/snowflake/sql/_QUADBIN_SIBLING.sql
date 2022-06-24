----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADBIN_SIBLING
(origin INT, dx INT, dy INT)
RETURNS INT
AS $$
    _ZXY_QUADBIN_SIBLING(
        QUADBIN_TOZXY(origin), dx, dy
    )
$$;