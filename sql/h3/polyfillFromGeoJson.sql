CREATE OR REPLACE FUNCTION jslibs.h3.polyfillFromGeoJson(geojson STRING, resolution NUMERIC)
 RETURNS ARRAY<STRING>
 LANGUAGE js AS
"""
var pol =JSON.parse(geojson)
return h3.polyfill(pol.coordinates[0],resolution,true);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js"]
);