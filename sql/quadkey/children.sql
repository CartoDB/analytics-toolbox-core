CREATE OR REPLACE FUNCTION jslibs.quadkey.children(quadkey STRING)
  RETURNS STRING
  DETERMINISTIC
  LANGUAGE js AS
"""
return children(quadkey);  
"""
OPTIONS (
  library=["gs://bigquery-jslibs/quadkey.js"]
);
