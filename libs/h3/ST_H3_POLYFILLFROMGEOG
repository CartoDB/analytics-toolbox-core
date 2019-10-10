CREATE OR REPLACE FUNCTION jslibs.h3.ST_H3_POLYFILLFROMGEOG(geo GEOGRAPHY, resolution NUMERIC) AS (
	jslibs.h3.polyfillFromGeoJson(ST_ASGEOJSON(geo),resolution)
);