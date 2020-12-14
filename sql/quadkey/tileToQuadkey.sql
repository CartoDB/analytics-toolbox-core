CREATE OR REPLACE FUNCTION jslibs.quadkey.tileToQuadkey(x NUMERIC, y NUMERIC, z NUMERIC)
  RETURNS STRING
  DETERMINISTIC
  LANGUAGE js AS
"""
return tileToQuadkey({ x: x, y: y }, z);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/quadkey.js"]
);

