CREATE OR REPLACE FUNCTION jslibs.s2.ST_S2(point GEOGRAPHY, resolution NUMERIC) AS (
  jslibs.s2.geoToS2(ST_Y(point),ST_X(point),resolution)
);
