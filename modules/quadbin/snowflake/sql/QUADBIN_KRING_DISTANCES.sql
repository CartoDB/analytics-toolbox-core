----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_KRING_DISTANCES
(origin INT, size INT)
RETURNS ARRAY
AS $$
    WITH __zxy AS (
       SELECT QUADBIN_TOZXY(origin) AS zxy 
    ),
    __t AS (
        SELECT
            QUADBIN_FROMZXY(
                zxy:z,
                MOD(zxy:x + dx.n + BITSHIFTLEFT(1, zxy:z), BITSHIFTLEFT(1, zxy:z)),
                zxy:y + dy.n
            ) __index,
            GREATEST(ABS(dx.n), ABS(dy.n)) __distance -- Chebychev distance
        FROM
            TABLE(_GENERATE_RANGE(-size,size)) dx,
            TABLE(_GENERATE_RANGE(-size,size)) dy,
            __zxy
        WHERE zxy:y + dy.n >= 0 and zxy:y + dy.n < BITSHIFTLEFT(1, zxy:z)
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