CREATE OR REPLACE FUNCTION jslibs.h3.compact(h3Set ARRAY<STRING>)
 RETURNS ARRAY<STRING>
 DETERMINISTIC
 LANGUAGE js AS
"""
return h3.compact(h3Set);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js"]
);