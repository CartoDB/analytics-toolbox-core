----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_FROMZXY(
  z INTEGER,
  x INTEGER,
  y INTEGER
)
RETURNS BIGINT
 AS
$BODY$
    WITH
    __ints AS (
        SELECT x::BIGINT << (32-z) AS x, y::BIGINT << (32-z) AS y, z
    ),
    __interleaved1 AS (
        SELECT
        (x | (x << 16)) & 281470681808895 AS x,
        (y | (y << 16)) & 281470681808895 AS y,
        z
        FROM __INTS
    ),
    __interleaved2 AS (
        SELECT
        (x | (x << 8)) & 71777214294589695 AS x,
        (y | (y << 8)) & 71777214294589695 AS y,
        z
        FROM __interleaved1
    ),
    __interleaved3 AS (
        SELECT
        (x | (x << 4)) & 1085102592571150095 AS x,
        (y | (y << 4)) & 1085102592571150095 AS y,
        z
        FROM __interleaved2
    ),
    __interleaved4 AS (
        SELECT
        (x | (x << 2)) & 3689348814741910323 AS x,
        (y | (y << 2)) & 3689348814741910323 AS y,
        z
        FROM __interleaved3
    ),
    __interleaved5 AS (
        SELECT
        (x | (x << 1)) & 6148914691236517205 AS x,
        (y | (y << 1)) & 6148914691236517205 AS y,
        z
        FROM __interleaved4
    )
    SELECT
      4611686018427387904
      | (1::BIGINT << 59) -- | (mode << 59) | (extra << 57)
      | (z::BIGINT << 52)
      | (x >> 12) | (y  >> 11)
      | ((1::BIGINT << (52 - (z << 1))) - 1)
    FROM __interleaved5
$BODY$
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
