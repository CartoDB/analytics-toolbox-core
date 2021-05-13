----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.TOPARENT`
(quadint INT64, resolution INT64)
RETURNS INT64
AS ((
    IF(resolution IS NULL OR resolution < 0 OR quadint IS NULL,
        ERROR('TOPARENT receiving wrong arguments')
        ,
        (
            WITH zxyContext AS(
                SELECT `@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint) zxy
            )
            SELECT `@@BQ_PREFIX@@quadkey.QUADINT_FROMZXY`(resolution, zxy.x >> (zxy.z - resolution),zxy.y >> (zxy.z - resolution))
            FROM zxyContext
        )
    )
));
