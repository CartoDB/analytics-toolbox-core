----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_TOQUADKEY`
(quadint INT64)
RETURNS STRING
AS((
  WITH
  __check AS (
       SELECT COALESCE(quadint, ERROR('quadint argument cannot be NULL')) AS quadint
  ),
  __parts AS (
       SELECT (quadint >> 5) AS xy, (quadint & 0x1F) AS z
       FROM __check
  ),
  __zxy AS (
      SELECT
        z,
        xy & ((1 << z) - 1) AS x,
        xy >> z AS Y
      FROM __parts
  ),
  __ints AS (
    SELECT CAST(x AS INT64) AS x, CAST(y AS INT64) AS y, z
    FROM __zxy
  ),
  __interleaved1 AS (
      SELECT
        (x | (x << 16)) & 0x0000FFFF0000FFFF AS x,
        (y | (y << 16)) & 0x0000FFFF0000FFFF AS y,
        z
      FROM __INTS
  ),
  __interleaved2 AS (
      SELECT
        (x | (x << 8)) & 0x00FF00FF00FF00FF AS x,
        (y | (y << 8)) & 0x00FF00FF00FF00FF AS y,
        z
      FROM __interleaved1
  ),
  __interleaved3 AS (
      SELECT
        (x | (x << 4)) & 0x0F0F0F0F0F0F0F0F AS x,
        (y | (y << 4)) & 0x0F0F0F0F0F0F0F0F AS y,
        z
      FROM __interleaved2
  ),
  __interleaved4 AS (
      SELECT
        (x | (x << 2)) & 0x3333333333333333 AS x,
        (y | (y << 2)) & 0x3333333333333333 AS y,
        z
      FROM __interleaved3
  ),
  __interleaved5 AS (
      SELECT
        (x | (x << 1)) & 0x5555555555555555 AS x,
        (y | (y << 1)) & 0x5555555555555555 AS y,
        z
      FROM __interleaved4
  ),
  __hex AS (
    SELECT FORMAT('%X', x | (y << 1)) AS hq, z FROM __interleaved5
  )
  SELECT
    LPAD(
      REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      LTRIM(hq, '0'), '0', '00'), '1', '01'), '2', '02'), '3', '03'), '4', '10'), '5', '11'), '6', '12'), '7', '13'), '8', '20'), '9', '21'), 'A', '22'), 'B', '23'), 'C', '30'), 'D', '31'), 'E', '32'), 'F', '33'),
      z, '0')
  FROM __hex
));