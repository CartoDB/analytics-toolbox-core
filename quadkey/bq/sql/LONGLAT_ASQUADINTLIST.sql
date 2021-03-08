-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.LONGLAT_ASQUADINTLIST`
    (longitude FLOAT64, latitude FLOAT64, __zoom_min INT64, __zoom_max INT64, __zoom_step INT64, __resolution INT64)
    RETURNS ARRAY<STRUCT<id INT64, z INT64, x INT64, y INT64>>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@QUADKEY_BQ_LIBRARY@@"])
AS """
    if (longitude === undefined || longitude === null || latitude === undefined || latitude === null) {
        return null;
    }
    const zoom_min = parseInt(__zoom_min);
    const zoom_max = parseInt(__zoom_max);
    const zoom_step = parseInt(__zoom_step);
    const resolution = parseInt(__resolution);

    const qintIdx = [];
    for (let i = zoom_min; i <= zoom_max; i += zoom_step) {
        const key = quadintFromLocation(longitude, latitude, i + resolution);
        const zxy = ZXYFromQuadint(key);
        qintIdx.push({ id : key.toString(), z : i, x : zxy.x  >>> resolution, y : zxy.y  >>> resolution});
    }
    return qintIdx;
""";