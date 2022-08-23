----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_SIBLING(
  quadbin BIGINT,
  direction TEXT
)
RETURNS BIGINT
 AS
$BODY$
    WITH
    __offsets AS (
        SELECT CASE direction
        WHEN 'left' THEN
            ARRAY[-1, 0]
        WHEN 'right' THEN
            ARRAY[1, 0]
        WHEN 'up' THEN
            ARRAY[0, -1]
        WHEN 'down' THEN
            ARRAY[0, 1]
        ELSE
            @@PG_SCHEMA@@.__CARTO_ERROR(FORMAT('Invalid direction "%s". Must be one of "left", "right", "up" or "down"', direction))::INT[]
        END AS dxy
    ),
    __zxy AS (
        SELECT @@PG_SCHEMA@@.QUADBIN_TOZXY(quadbin) AS origin
    )
    SELECT CASE
      WHEN (origin->>'y')::INT + dxy[2] < 0 OR (origin->>'y')::INT + dxy[2] >= (1 << (origin->>'z')::INT)
      THEN NULL
      ELSE
        @@PG_SCHEMA@@.QUADBIN_FROMZXY(
            (origin->>'z')::INT,
            MOD( (origin->>'x')::INT + dxy[1], (1 << (origin->>'z')::INT ))
            + CASE WHEN (origin->>'x')::INT + dxy[1] < 0 THEN (1 << (origin->>'z')::INT) ELSE 0 END,
            (origin->>'y')::INT + dxy[2]
        )
    END
    FROM __zxy, __offsets
$BODY$
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
