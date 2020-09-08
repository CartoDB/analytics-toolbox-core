CREATE OR REPLACE FUNCTION jslibs.s2.ST_S2(latitude FLOAT64, longitude FLOAT64, level NUMERIC) AS (
  (SELECT STRING_AGG(FORMAT('%02x', CAST(jslibs.s2.latLngToId(latitude, longitude, level) AS INT64) >> (byte * 8) & 0xff), '' ORDER BY byte DESC)
   FROM UNNEST(GENERATE_ARRAY(0, 7)) AS byte)
);

