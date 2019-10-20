CREATE FUNCTION jslibs.turf.buffer(geojson STRING,radius NUMERIC, options STRUCT<unit STRING,steps NUMERIC>)
 RETURNS STRING
 LANGUAGE js AS
"""
var buffer = turf.buffer(JSON.parse(geojson),radius,{'unit':options.unit,'steps':options.steps});
return JSON.stringify(buffer.geometry);
"""
OPTIONS (
 library=["gs://bigquery-jslibs/turf.min.js"]
);