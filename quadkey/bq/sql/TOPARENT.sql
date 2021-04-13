-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.TOPARENT`
    (quadint INT64, resolution INT64)
    RETURNS INT64
AS ((
    IF(resolution IS NULL OR resolution < 0 OR quadint IS NULL,
        ERROR("TOPARENT receiving wrong arguments")
    ,
    (
        WITH zxyContext AS(
            SELECT `@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.ZXY_FROMQUADINT(quadint) zxy
        )
        SELECT `@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.QUADINT_FROMZXY(resolution, zxy.x >> (zxy.z - resolution),zxy.y >> (zxy.z - resolution)) FROM zxyContext
        )
    )
));
