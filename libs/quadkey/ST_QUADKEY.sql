CREATE OR REPLACE FUNCTION jslibs.quadkey.ST_QUADKEY(point GEOGRAPHY, resolution NUMERIC) AS (
	jslibs.quadkey.locationToQuadkey(ST_Y(point),ST_X(point),resolution)
);