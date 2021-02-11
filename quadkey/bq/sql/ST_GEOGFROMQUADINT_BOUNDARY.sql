-----------------------------------------------------------------------
--
-- Copyright (C) 2020 - 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.ST_GEOGFROMQUADINT_BOUNDARY`
    (quadint INT64) 
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.GEOJSONBOUNDARY_FROM_QUADINT(quadint))
);