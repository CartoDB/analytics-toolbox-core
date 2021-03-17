-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.__POLYFILL_FROMGEOJSON`
    (geojson STRING, resolution INT64)
    RETURNS ARRAY<INT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@QUADKEY_BQ_LIBRARY@@"])
AS """
    if(!geojson || resolution == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    const intResolution = parseInt(resolution);
    let pol = JSON.parse(geojson);
    let quadints = geojsonToQuadints(pol, {min_zoom: intResolution, max_zoom: intResolution});
    return quadints.map(String);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.ST_ASQUADINT_POLYFILL`
    (geo GEOGRAPHY, resolution INT64)
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.__POLYFILL_FROMGEOJSON(ST_ASGEOJSON(geo),resolution)
);