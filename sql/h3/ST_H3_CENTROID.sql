CREATE OR REPLACE FUNCTION jslibs.h3.ST_H3_CENTROID(h3Index STRING) AS (
	jslibs.h3.h3ToGeoWkt(h3Index)
);