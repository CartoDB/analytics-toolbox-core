CREATE OR REPLACE FUNCTION jslibs.quadkey.locationToQuadkey(latitude FLOAT64, longitude FLOAT64, resolution NUMERIC)
  RETURNS STRING
  LANGUAGE js AS
"""
return locationToQuadkey({ lat: latitude, lng: longitude }, level);  
"""
OPTIONS (
  library=["gs://bigquery-jslibs/quadkey.js"]
);
