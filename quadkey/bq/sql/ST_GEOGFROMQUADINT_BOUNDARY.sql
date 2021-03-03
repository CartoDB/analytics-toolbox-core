-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.GEOJSONBOUNDARY_FROMQUADINT`
    (quadint INT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@QUADKEY_BQ_LIBRARY@@"])
AS """
    let geojson = quadintToGeoJSON(quadint);
    return JSON.stringify(geojson);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.ST_GEOGFROMQUADINT_BOUNDARY`
    (quadint INT64) 
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.GEOJSONBOUNDARY_FROMQUADINT(quadint))
);