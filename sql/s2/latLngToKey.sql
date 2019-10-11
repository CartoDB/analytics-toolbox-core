CREATE OR REPLACE FUNCTION jslibs.s2.latLngToKey(latitude FLOAT64, longitude FLOAT64, level NUMERIC)
  RETURNS STRING
  LANGUAGE js AS
"""
var S2 = require('s2-geometry').S2;
return S2.latLngToKey(latitude, longitude, resolution);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/s2geometry.js"]
);