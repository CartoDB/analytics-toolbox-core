CREATE OR REPLACE FUNCTION jslibs.quadkey.ST_QUADKEY_POLYFILLFROMGEOG(geo GEOGRAPHY, resolution NUMERIC) AS (
	jslibs.quadkey.polyfillFromGeoJson(ST_ASGEOJSON(geo),resolution)
);