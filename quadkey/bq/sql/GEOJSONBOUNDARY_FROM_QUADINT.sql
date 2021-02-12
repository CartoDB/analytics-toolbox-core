-----------------------------------------------------------------------
--
-- Copyright (C) 2020 - 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.GEOJSONBOUNDARY_FROM_QUADINT`
    (quadint INT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@BQ_LIBRARY_QUADKEY@@"])
AS """
    var b = bbox(quadint);  
    var geojson = {
        "type": "Polygon", 
        "coordinates": [[
            [b.min.lng,b.min.lat],
            [b.min.lng,b.max.lat],
            [b.max.lng,b.max.lat],
            [b.max.lng,b.min.lat],
            [b.min.lng,b.min.lat]
        ]]
    };
    return JSON.stringify(geojson);
""";