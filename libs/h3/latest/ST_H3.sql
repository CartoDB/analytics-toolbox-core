--Get the center of the hexagon as GEOMETRY POINT
CREATE OR REPLACE FUNCTION jslibs.h3.ST_H3(point GEOGRAPHY, resolution NUMERIC) AS (
	jslibs.h3.h3Index(ST_Y(point),ST_X(point),resolution)
);
