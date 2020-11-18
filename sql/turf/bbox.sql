CREATE OR REPLACE FUNCTION jslibs.turf.bbox(geojson STRING)
 RETURNS ARRAY<FLOAT64>
 DETERMINISTIC
 LANGUAGE js AS
"""
	return turf.bbox(JSON.parse(geojson));
"""
OPTIONS (
 library=["gs://bigquery-jslibs/turf.min.js"]
);