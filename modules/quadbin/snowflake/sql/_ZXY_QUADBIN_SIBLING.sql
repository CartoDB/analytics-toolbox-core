----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _ZXY_QUADBIN_SIBLING
(origin OBJECT, dx INT, dy INT)
RETURNS INT
IMMUTABLE
AS $$
    IFF(origin:y + dy >= 0 AND origin:y + dy < BITSHIFTLEFT(1, origin:z),
        QUADBIN_FROMZXY(
            origin:z,
            MOD(origin:x + dx, BITSHIFTLEFT(1, origin:z)) + IFF(origin:x + dx < 0, BITSHIFTLEFT(1, origin:z), 0),
            origin:y + dy
        ),
        NULL
    )
$$;

