CREATE OR REPLACE FUNCTION jslibs.quadkey.ST_QUADKEY_BOUNDARY(quadkey STRING) AS (
	ST_GEOGFROMGEOJSON(jslibs.quadkey.quadkeyToGeoJsonBoundary(quadkey))
);