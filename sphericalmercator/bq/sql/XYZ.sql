-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_SPHERICALMERCATOR@@.XYZ`
    (bbox ARRAY<FLOAT64>, zoom NUMERIC, tileSize NUMERIC)
    RETURNS STRUCT<minX NUMERIC,minY NUMERIC,maxX NUMERIC,maxY NUMERIC>
    LANGUAGE js
    OPTIONS (library=["@@SPHERICALMERCATOR_BQ_LIBRARY@@"])
AS """
    var merc = new SphericalMercator({size: tileSize});
    return merc.xyz(bbox,zoom);
""";
