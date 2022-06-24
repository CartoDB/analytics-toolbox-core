----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_KRING_DISTANCES
(origin BIGINT, size INT)
RETURNS ARRAY
AS $$
    WITH __zxy AS (
       SELECT QUADBIN_TOZXY(origin) AS zxy
    ),
    __t AS (
        SELECT
            QUADBIN_FROMZXY(
                zxy:z,
                MOD(zxy:x + dx.VALUE + BITSHIFTLEFT(1, zxy:z), BITSHIFTLEFT(1, zxy:z)),
                zxy:y + dy.VALUE
            ) __index,
            GREATEST(ABS(dx.VALUE), ABS(dy.VALUE)) __distance -- Chebychev distance
        FROM
            TABLE(FLATTEN(_GENERATE_RANGE(-size,size))) dx,
            TABLE(FLATTEN(_GENERATE_RANGE(-size,size))) dy,
            __zxy
        WHERE zxy:y + dy.VALUE >= 0 and zxy:y + dy.VALUE < BITSHIFTLEFT(1, zxy:z)
    ),
    __t_agg AS (
        SELECT
            __index,
            MIN(__distance) AS __distance
        FROM __t
        GROUP BY __index
    )
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT('index', __index, 'distance', __distance))
    FROM __t_agg
$$;