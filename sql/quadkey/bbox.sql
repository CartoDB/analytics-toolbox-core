CREATE OR REPLACE FUNCTION jslibs.quadkey.bbox(quadkey STRING)
  RETURNS ARRAY<STRING>
  DETERMINISTIC
  LANGUAGE js AS
"""
var b= bbox(quadkey);  
return [b.min.lng,b.min.lat,b.max.lng,b.max.lat];
"""
OPTIONS (
  library=["gs://bigquery-jslibs/quadkey.js"]
);
