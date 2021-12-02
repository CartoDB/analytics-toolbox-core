CREATE OR REPLACE TABLE `@@BQ_PREFIX@@carto.places` (
  geoid INTEGER,
  do_date TIMESTAMP,
  name STRING,
  fclass STRING,
  fcode STRING,
  country STRING,
  admin1 STRING,
  admin2 STRING,
  admin3 STRING,
  admin4 STRING,
  population INTEGER,
  geom GEOGRAPHY
);

INSERT INTO `@@BQ_PREFIX@@carto.places`(geoid, name, geom, fclass, fcode, country, admin1, admin2, admin3, admin4, population)
SELECT geonameid, name, ST_GEOGPOINT(longitude, latitude), fclass, fcode, country,  admin1, admin2, admin3, admin4, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE fcode IN ('PCLI', 'PCLD', 'PCLH', 'TERR', 'PCLIX', 'ADM1', 'ADM2', 'ADM3', 'ADM4') OR fclass = 'P';

-- Set release date
UPDATE `@@BQ_PREFIX@@carto.places`
 SET do_date = CAST(CONCAT(SUBSTR('@@GEONAMES_RELEASE@@', 1, 4), '-', SUBSTR('@@GEONAMES_RELEASE@@', 5, 2), '-01') AS TIMESTAMP)
 WHERE TRUE;

