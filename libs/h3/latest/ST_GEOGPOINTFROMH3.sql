--Get the center of the hexagon as GEOMETRY POINT
CREATE OR REPLACE FUNCTION jslibs.h3.ST_GEOGPOINTFROMH3(h3Index STRING) AS (
	ST_GEOGFROMTEXT(jslibs.h3.h3ToWkt(h3Index))
);
