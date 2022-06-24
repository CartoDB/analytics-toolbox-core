CREATE OR REPLACE FUNCTION QUADBIN_TOZXY
(quadbin BIGINT)
RETURNS OBJECT
AS $$
WITH __interleaved AS (
  SELECT
    BITAND(BITSHIFTRIGHT(quadbin, 59), 7) AS mode,
    BITAND(BITSHIFTRIGHT(quadbin, 57), 3) AS extra,
    BITAND(BITSHIFTRIGHT(quadbin, 52), 31) AS z,
    BITSHIFTLEFT(
      BITAND(
        quadbin,
        4503599627370495
      ),
      12
    ) AS q
),
__deinterleaved1 AS (
  SELECT
    z,
    q AS x,
    BITSHIFTRIGHT(q, 1) AS y
  FROM
    __interleaved
),
__deinterleaved2 AS (
  SELECT
    z,
    BITAND(
      x,
      6148914691236517205
    ) AS x,
    BITAND(
      y,
      6148914691236517205
    ) AS y
  FROM
    __deinterleaved1
),
__deinterleaved3 AS (
  SELECT
    z,
    BITAND(
      BITOR(x, BITSHIFTRIGHT(x, 1)),
      3689348814741910323
    ) AS x,
    BITAND(
      BITOR(y, BITSHIFTRIGHT(y, 1)),
      3689348814741910323
    ) AS y
  FROM
    __deinterleaved2
),
__deinterleaved4 AS (
  SELECT
    z,
    BITAND(
      BITOR(x, BITSHIFTRIGHT(x, 2)),
      1085102592571150095
    ) AS x,
    BITAND(
      BITOR(y, BITSHIFTRIGHT(y, 2)),
      1085102592571150095
    ) AS y
  FROM
    __deinterleaved3
),
__deinterleaved5 AS (
  SELECT
    z,
    BITAND(
      BITOR(x, BITSHIFTRIGHT(x, 4)),
      71777214294589695
    ) AS x,
    BITAND(
      BITOR(y, BITSHIFTRIGHT(y, 4)),
      71777214294589695
    ) AS y
  FROM
    __deinterleaved4
),
__deinterleaved6 AS (
  SELECT
    z,
    BITAND(
      BITOR(x, BITSHIFTRIGHT(x, 8)),
      281470681808895
    ) AS x,
    BITAND(
      BITOR(y, BITSHIFTRIGHT(y, 8)),
      281470681808895
    ) AS y
  FROM
    __deinterleaved5
),
__deinterleaved7 AS (
  SELECT
    z,
    BITAND(
      BITOR(x, BITSHIFTRIGHT(x, 16)),
      4294967295
    ) AS x,
    BITAND(
      BITOR(y, BITSHIFTRIGHT(y, 16)),
      4294967295
    ) AS y
  FROM
    __deinterleaved6
)
SELECT
  OBJECT_CONSTRUCT(
    'z',
    z,
    'x',
    BITSHIFTRIGHT(x, (32 - z)),
    'y',
    BITSHIFTRIGHT(y, (32 - z))
  )
FROM
  __deinterleaved7
$$;