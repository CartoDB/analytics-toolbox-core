CREATE OR REPLACE TABLE `@@BQ_PREFIX@@carto.postalcodes` (
  geoid STRING, -- unique ID: concatenation of country_code and postal_code
  do_date TIMESTAMP,
  country_code STRING, -- 2-character ISO code
  code STRING,  -- Search code
  postal_code STRING, -- Postal Code
  -- place_geoid INTEGER, -- we could match a geoid by place_name, admin_code1, admin_code2, admin_code3, admin_code4
  accuracy INT64,
  geom GEOGRAPHY
) CLUSTER BY country_code, code;

INSERT INTO `@@BQ_PREFIX@@carto.postalcodes`(geoid, country_code, postal_code, geom, accuracy)
SELECT
  CONCAT(country_code, postal_code), country_code, postal_code,
  ST_CENTROID_AGG(ST_GEOGPOINT(longitude, latitude)),
  CASE WHEN COUNT(*) > 1 THEN 6 ELSE MAX(accuracy) END
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@postalcodes`
GROUP BY country_code, postal_code;

-- TODO: fix chicken-egg problem: __PC_CODE is in geocoding module which requires these tables
UPDATE `@@BQ_PREFIX@@carto.postalcodes`
SET code = `@@BQ_PREFIX@@carto.__PC_CODE`(postal_code) WHERE TRUE;

-- Set release date
UPDATE `@@BQ_PREFIX@@carto.postalcodes`
 SET do_date = CAST(CONCAT(SUBSTR('@@GEONAMES_RELEASE@@', 1, 4), '-', SUBSTR('@@GEONAMES_RELEASE@@', 5, 2), '-01') AS TIMESTAMP)
 WHERE TRUE;
