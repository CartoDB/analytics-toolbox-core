----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_KRING
(origin INT, size INT)
RETURNS ARRAY
AS $$
    WITH __zxy AS (
       SELECT QUADBIN_TOZXY(origin) as zxy 
    )
    SELECT ARRAY_AGG(
        DISTINCT (QUADBIN_FROMZXY(
            zxy:z,
            MOD(zxy:x + dx.n + BITSHIFTLEFT(1, zxy:z), BITSHIFTLEFT(1, zxy:z)),
            zxy:y + dy.n)
        )
    )
    FROM
        TABLE(_GENERATE_RANGE(-size, size)) dx,
        TABLE(_GENERATE_RANGE(-size, size)) dy,
        __zxy
    WHERE zxy:y + dy.n >= 0 AND zxy:y + dy.n < BITSHIFTLEFT(1, zxy:z)
$$;