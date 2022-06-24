----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_SIBLING
(quadbin INT, direction STRING)
RETURNS INT
AS $$
  (WITH _dxy AS (
    SELECT CASE direction
        WHEN 'left' THEN
            OBJECT_CONSTRUCT('x', -1, 'y', 0)
        WHEN 'right' THEN
            OBJECT_CONSTRUCT('x', 1, 'y', 0)
        WHEN 'up' THEN
            OBJECT_CONSTRUCT('x', 0, 'y', -1)
        WHEN 'down' THEN
            OBJECT_CONSTRUCT('x', 0, 'y', 1)
        ELSE
            NULL
    END AS d, QUADBIN_TOZXY(quadbin) AS t
  )
  SELECT IFF(t:y + d:y >= 0 AND t:y + d:y < BITSHIFTLEFT(1, t:z),
        QUADBIN_FROMZXY(
            t:z,
            MOD(t:x + d:x, BITSHIFTLEFT(1, t:z)) + IFF(t:x + d:x < 0, BITSHIFTLEFT(1, t:z), 0),
            t:y + d:y
        ),
        NULL
    )
   FROM _dxy)
$$;
