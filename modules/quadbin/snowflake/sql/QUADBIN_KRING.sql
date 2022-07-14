----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

-- FIXME: slow

CREATE OR REPLACE FUNCTION QUADBIN_KRING
(origin BIGINT, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    WITH __zxy AS (
       SELECT _QUADBIN_TOZXY(origin) as zxy
    )
    SELECT ARRAY_AGG(
        DISTINCT (QUADBIN_FROMZXY(
            zxy:z,
            MOD(zxy:x + dx.VALUE + BITSHIFTLEFT(1, zxy:z), BITSHIFTLEFT(1, zxy:z)),
            zxy:y + dy.VALUE)
        )
    )
    FROM
        TABLE(FLATTEN(_GENERATE_RANGE(-size, size))) dx,
        TABLE(FLATTEN(_GENERATE_RANGE(-size, size))) dy,
        __zxy
    WHERE zxy:y + dy.VALUE >= 0 AND zxy:y + dy.VALUE < BITSHIFTLEFT(1, zxy:z)
$$;