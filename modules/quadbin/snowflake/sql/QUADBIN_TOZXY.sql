CREATE OR REPLACE FUNCTION QUADBIN_TOZXY
(quadbin INT)
RETURNS OBJECT
AS $$
WITH
__interleaved AS (
  SELECT
    BITAND(BITSHIFTRIGHT(quadbin, 59), 7) AS mode,
    BITAND(BITSHIFTRIGHT(quadbin, 57), 3) AS extra,
    BITAND(BITSHIFTRIGHT(quadbin, 52), 31) AS z,
    BITSHIFTLEFT(BITAND(quadbin, TO_NUMBER('fffffffffffffff', 'XXXXXXXXXXXXXXXX')), 12) AS q
),
__deinterleaved1 AS (
  SELECT z, q AS x, BITSHIFTRIGHT(q, 1) AS y
  FROM __interleaved
),
__deinterleaved2 AS (
  SELECT
    z,
    BITAND(x, TO_NUMBER('5555555555555555', 'XXXXXXXXXXXXXXXX')) AS x,
    BITAND(y, TO_NUMBER('5555555555555555', 'XXXXXXXXXXXXXXXX')) AS y
  FROM __deinterleaved1
),
__deinterleaved3 AS (
  SELECT
    z,
    BITAND(BITOR(x, BITSHIFTRIGHT(x, 1)), TO_NUMBER('3333333333333333', 'XXXXXXXXXXXXXXXX')) AS x,
    BITAND(BITOR(y, BITSHIFTRIGHT(y, 1)), TO_NUMBER('3333333333333333', 'XXXXXXXXXXXXXXXX')) AS y
  FROM __deinterleaved2
),
__deinterleaved4 AS (
  SELECT
    z,
    BITAND(BITOR(x, BITSHIFTRIGHT(x, 2)), TO_NUMBER('0f0f0f0f0f0f0f0f', 'XXXXXXXXXXXXXXXX')) AS x,
    BITAND(BITOR(y, BITSHIFTRIGHT(y, 2)), TO_NUMBER('0f0f0f0f0f0f0f0f', 'XXXXXXXXXXXXXXXX')) AS y
  FROM __deinterleaved3
),
__deinterleaved5 AS (
  SELECT
    z,
    BITAND(BITOR(x, BITSHIFTRIGHT(x, 4)), TO_NUMBER('00ff00ff00ff00ff', 'XXXXXXXXXXXXXXXX')) AS x,
    BITAND(BITOR(y, BITSHIFTRIGHT(y, 4)), TO_NUMBER('00ff00ff00ff00ff', 'XXXXXXXXXXXXXXXX')) AS y
  FROM __deinterleaved4
),
__deinterleaved6 AS (
  SELECT
    z,
    BITAND(BITOR(x, BITSHIFTRIGHT(x, 8)), TO_NUMBER('0000ffff0000ffff', 'XXXXXXXXXXXXXXXX')) AS x,
    BITAND(BITOR(y, BITSHIFTRIGHT(y, 8)), TO_NUMBER('0000ffff0000ffff', 'XXXXXXXXXXXXXXXX')) AS y
  FROM __deinterleaved5
),
__deinterleaved7 AS (
  SELECT
    z,
    BITAND(BITOR(x, BITSHIFTRIGHT(x, 16)), TO_NUMBER('00000000ffffffff', 'XXXXXXXXXXXXXXXX')) AS x,
    BITAND(BITOR(y, BITSHIFTRIGHT(y, 16)), TO_NUMBER('00000000ffffffff', 'XXXXXXXXXXXXXXXX')) AS y
  FROM __deinterleaved6
)
SELECT OBJECT_CONSTRUCT('z', z, 
                        'x', BITSHIFTRIGHT(x, (32-z)), 
                        'y', BITSHIFTRIGHT(y, (32-z)))
FROM __deinterleaved7
$$;
