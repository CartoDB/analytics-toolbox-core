-----------------------------------------------------------------------
--
-- Copyright (C) 2020 - 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.POLYFILL_FROMGEOJSON`
    (geojson STRING, level NUMERIC)
    RETURNS ARRAY<INT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@BQ_LIBRARY_QUADKEY@@"])
AS """
    var pol = JSON.parse(geojson);
    return geojsonToQuadints(pol, {min_zoom: level,max_zoom: level});
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.ST_ASQUADINTPOLYFILL`
    (geo GEOGRAPHY, resolution NUMERIC)
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.POLYFILL_FROMGEOJSON(ST_ASGEOJSON(geo),resolution)
);