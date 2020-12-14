CREATE OR REPLACE FUNCTION `jslibs.placekey.ST_PLACEKEYWHERE`(point GEOGRAPHY) AS (
jslibs.placekey.geoToPlacekey(ST_Y(point),ST_X(point))
);