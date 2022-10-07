----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__BBOX_FROM_GEOJSON`
(geojson STRING)
RETURNS ARRAY<FLOAT64>
DETERMINISTIC
LANGUAGE js
OPTIONS (library = ["@@BQ_LIBRARY_BUCKET@@"])
AS """
    return lib.random.bbox(JSON.parse(geojson));
""";
