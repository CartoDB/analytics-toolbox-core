----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@geohash.LONGLAT_ASGEOHASH`
(longitude FLOAT64, latitude FLOAT64, resolution INT64)
RETURNS STRING
AS ((
    SELECT ST_GEOHASH(ST_GEOGPOINT(longitude, latitude), resolution)
));