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
    var b = bbox(quadint);  
    var geojson = {
        "type": "Polygon", 
        "coordinates": [[
            [b.min.lng, b.min.lat],
            [b.min.lng, b.max.lat],
            [b.max.lng, b.max.lat],
            [b.max.lng, b.min.lat],
            [b.min.lng, b.min.lat]
        ]]
    };
    return JSON.stringify(geojson);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.ST_GEOGFROMQUADINT_BOUNDARY`
    (quadint INT64) 
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.GEOJSONBOUNDARY_FROMQUADINT(quadint))
);