----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

DROP FUNCTION IF EXISTS QUADBIN_TOZXY(BIGINT);

CREATE OR REPLACE FUNCTION QUADBIN_TOZXY(
  quadbin BIGINT
)
RETURNS JSON -- {z, x, y}
 AS
$BODY$
    WITH
    __interleaved AS (
        SELECT
            ((quadbin >> 59))::INT & 7 AS mode,
            ((quadbin >> 57) & 3)::INT AS extra,
            ((quadbin >> 52) & 31)::INT AS z,
            (quadbin & 4503599627370495) << 12 AS q
    ),
    __deinterleaved1 AS (
        SELECT z, q AS x, q >> 1 AS y FROM __interleaved
    ),
    __deinterleaved2 AS (
        SELECT
            z,
            x & 6148914691236517205 AS x,
            y & 6148914691236517205 AS y
        FROM __deinterleaved1
    ),
    __deinterleaved3 AS (
        SELECT
            z,
            (x | (x >> 1)) & 3689348814741910323 AS x,
            (y | (y >> 1)) & 3689348814741910323 AS y
        FROM __deinterleaved2
    ),
    __deinterleaved4 AS (
        SELECT
            z,
            (x | (x >> 2)) & 1085102592571150095 AS x,
            (y | (y >> 2)) & 1085102592571150095 AS y
        FROM __deinterleaved3
    ),
    __deinterleaved5 AS (
        SELECT
            z,
            (x | (x >> 4)) & 71777214294589695 AS x,
            (y | (y >> 4)) & 71777214294589695 AS y
        FROM __deinterleaved4
    ),
    __deinterleaved6 AS (
        SELECT
            z,
            (x | (x >> 8)) & 281470681808895 AS x,
            (y | (y >> 8)) & 281470681808895 AS y
        FROM __deinterleaved5
    ),
    __deinterleaved7 AS (
        SELECT
            z,
            (x | (x >> 16)) & 4294967295 AS x,
            (y | (y >> 16)) & 4294967295 AS y
        FROM __deinterleaved6
    )
    SELECT
      json_build_object('z', z, 'x', (x >> (32-z)), 'y', (y >> (32-z)))
    FROM __deinterleaved7
$BODY$
  LANGUAGE SQL;
