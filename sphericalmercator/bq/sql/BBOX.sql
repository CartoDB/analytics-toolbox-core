-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_SPHERICALMERCATOR@@.BBOX`
(x NUMERIC, y NUMERIC, zoom NUMERIC, tileSize NUMERIC )
    RETURNS ARRAY<FLOAT64>
    LANGUAGE js
    OPTIONS (library=["@@SPHERICALMERCATOR_BQ_LIBRARY@@"]) 
AS """
    var merc = new SphericalMercator({size: tileSize});
    return merc.bbox(x,y,zoom);
""";