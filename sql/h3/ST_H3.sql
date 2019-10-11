CREATE OR REPLACE FUNCTION jslibs.h3.ST_H3(point GEOGRAPHY, resolution NUMERIC) AS (
	jslibs.h3.geoToH3(ST_Y(point),ST_X(point),resolution)
);