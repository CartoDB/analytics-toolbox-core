CREATE OR REPLACE FUNCTION jslibs.quadkey.sibling(quadkey STRING, direction STRING)
  RETURNS STRING
  DETERMINISTIC
  LANGUAGE js AS
"""
return sibling(quadkey,direction);  
"""
OPTIONS (
  library=["gs://bigquery-jslibs/quadkey.js"]
);
