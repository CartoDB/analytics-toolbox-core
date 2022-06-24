----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __QUADBIN_FROMQUADINT(
  quadint BIGINT
)
RETURNS BIGINT
 AS
$BODY$
    WITH
    __zxy1 AS (
        SELECT
            (quadint >> 5) AS xy,
            (quadint & 31)::INT AS z
    ),
    __zxy2 AS (
        SELECT
            z,
            (xy & ((1 << z) - 1))::INT AS x,
            (xy >> z)::INT AS Y
        FROM __zxy1
    )
    SELECT @@PG_PREFIX@@carto.QUADBIN_FROMZXY(z, x, y)
    FROM __zxy2
$BODY$
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
