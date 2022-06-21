----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__QUADBIN_FROMQUADINT`
(quadint INT64)
RETURNS INT64 AS ((
    WITH
    __zxy AS (
        SELECT `@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint) as tile
    )
    SELECT `@@BQ_PREFIX@@carto.QUADBIN_FROMZXY`(tile.z, tile.x, tile.y)
    FROM __zxy
));