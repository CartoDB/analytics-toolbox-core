CREATE OR REPLACE FUNCTION jslibs.h3.h3GetFaces(h3Index STRING)
 RETURNS ARRAY<NUMERIC>
 LANGUAGE js AS
"""
return h3.h3GetFaces(h3Index);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3/latest/h3-js.umd.js"]
);