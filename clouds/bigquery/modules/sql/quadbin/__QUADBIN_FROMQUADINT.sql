----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_FROMQUADINT`
(quadint INT64)
RETURNS INT64 AS ((
    WITH __zxy AS (
        SELECT (quadint >> 5) AS xy, (quadint & 0x1F) AS z
    )
    SELECT `@@BQ_DATASET@@.QUADBIN_FROMZXY`(z, xy & ((1 << z) - 1), xy >> z)
    FROM __zxy
));
