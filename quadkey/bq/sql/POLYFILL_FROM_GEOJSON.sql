-----------------------------------------------------------------------
--
-- Copyright (C) 2020 - 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.POLYFILL_FROM_GEOJSON`
    (geojson STRING, level NUMERIC)
    RETURNS ARRAY<INT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@BQ_LIBRARY_QUADKEY@@"])
AS """
    var pol = JSON.parse(geojson);
    return geojsonToQuadints(pol, {min_zoom: level,max_zoom: level});
""";