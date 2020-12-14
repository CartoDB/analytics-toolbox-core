CREATE OR REPLACE FUNCTION jslibs.h3.hexRing(h3Index STRING, ringSize NUMERIC)
 RETURNS ARRAY<STRING>
 DETERMINISTIC
 LANGUAGE js AS
"""
return h3.hexRing(h3Index, ringSize);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js"]
);