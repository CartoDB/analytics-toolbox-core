CREATE OR REPLACE FUNCTION jslibs.turf.simplify(geojson STRING, options STRUCT<tolerance NUMERIC, highQuality BOOL>)
 RETURNS STRING
 DETERMINISTIC
 LANGUAGE js AS
"""
var buffer = turf.simplify(JSON.parse(geojson),{'tolerance':options.tolerance,'highQuality':options.highQuality, 'mutate': true});
return JSON.stringify(buffer);
"""
OPTIONS (
 library=["gs://bigquery-jslibs/turf.min.js"]
);
