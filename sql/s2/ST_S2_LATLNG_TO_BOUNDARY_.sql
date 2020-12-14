CREATE OR REPLACE FUNCTION jslibs.s2.ST_S2_BOUNDARY(latitude FLOAT64, longitude FLOAT64, level NUMERIC) AS (
	ST_GEOGFROMGEOJSON(jslibs.s2.latLngToCornerLatLngs(latitude, longitude, level))
);