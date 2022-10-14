----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_RESOLUTION`
(id INT64) AS (
  (SELECT (61 - STRPOS(STRING_AGG(CAST(id >> bit & 0x1 AS STRING), '' ORDER BY bit), '1')) >> 1
   FROM UNNEST(GENERATE_ARRAY(0, 63)) AS bit)
);
