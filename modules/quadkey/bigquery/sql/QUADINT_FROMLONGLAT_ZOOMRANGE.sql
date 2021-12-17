----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_FROMLONGLAT_ZOOMRANGE`
(longitude FLOAT64, latitude FLOAT64, zoom_min INT64, zoom_max INT64, zoom_step INT64, resolution INT64)
RETURNS ARRAY<STRUCT<id INT64, z INT64, x INT64, y INT64>>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (longitude === undefined || longitude === null || latitude === undefined || latitude === null) {
        return null;
    }
    const zoomMin = parseInt(zoom_min);
    const zoomMax = parseInt(zoom_max);
    const zoomStep = parseInt(zoom_step);
    const intResolution = parseInt(resolution);

    const qintIdx = [];
    for (let i = zoomMin; i <= zoomMax; i += zoomStep) {
        const key = quadkeyLib.quadintFromLocation(longitude, latitude, i + intResolution);
        const zxy = quadkeyLib.ZXYFromQuadint(key);
        qintIdx.push({ id : key.toString(), z : i, x : zxy.x  >>> intResolution, y : zxy.y  >>> intResolution});
    }
    return qintIdx;
""";