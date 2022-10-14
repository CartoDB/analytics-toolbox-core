----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_TOCHILDREN`
(id INT64, resolution INT64 ) AS (
(
  ARRAY(
SELECT id + (s2_ << (60 - (2 * resolution))) AS s2
FROM UNNEST(GENERATE_ARRAY(1 - (1 << (2 * (resolution - `@@BQ_DATASET@@.S2_RESOLUTION`(id)))), (1 << (2 * (resolution - `@@BQ_DATASET@@.S2_RESOLUTION`(id)))) - 1, 2)) AS s2_
))
);
