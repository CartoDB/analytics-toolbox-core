CREATE OR REPLACE TABLE `@@BQ_PREFIX@@carto.names` (
  geoid INTEGER,
  do_date TIMESTAMP,
  code STRING,
  name STRING,
  level INTEGER,
  level0 STRING,
  level1 STRING,
  level2 STRING,
  level3 STRING,
  level4 STRING,
  level_id STRING,
  relevance INTEGER,
  main BOOLEAN,
  preferred BOOLEAN,
  language STRING
) CLUSTER BY code;

-- countries
INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, main, relevance)
SELECT name, geonameid, 0, country, country, TRUE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE admin1 = '00' AND fcode IN ('PCLI', 'PCLD', 'PCLH', 'TERR', 'PCLIX');

INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, main, relevance)
SELECT asciiname, geonameid, 0, country, country, FALSE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE admin1 = '00' AND fcode IN ('PCLI', 'PCLD', 'PCLH', 'TERR', 'PCLIX');

-- admin 1
INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, level1, main, relevance)
SELECT name, geonameid, 1, admin1, country, admin1, TRUE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE fcode = 'ADM1';

INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, level1, main, relevance)
SELECT asciiname, geonameid, 1, admin1, country, admin1, FALSE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE fcode = 'ADM1';

-- admin 2
INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, level1, level2, main, relevance)
SELECT name, geonameid, 2, admin2, country, admin1, admin2, TRUE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE fcode = 'ADM2';

INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, level1, level2, main, relevance)
SELECT asciiname, geonameid, 2, admin2, country, admin1, admin2, FALSE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE fcode = 'ADM2';

-- admin 3
INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, level1, level2, level3,  main, relevance)
SELECT name, geonameid, 3, admin3, country, admin1, admin2, admin3, TRUE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE fcode = 'ADM3';

INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, level1, level2, level3,  main, relevance)
SELECT asciiname, geonameid, 3, admin3, country, admin1, admin2, admin3, FALSE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE fcode = 'ADM3';

-- admin 4
INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, level1, level2, level3,  level4, main, relevance)
SELECT name, geonameid, 4, admin4, country, admin1, admin2, admin3, admin4, TRUE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE fcode = 'ADM4';

INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, level1, level2, level3,  level4, main, relevance)
SELECT asciiname, geonameid, 4, admin4, country, admin1, admin2, admin3, admin4, FALSE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE fcode = 'ADM4';

-- cities
INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level0, level1, level2, level3,  level4, main, relevance)
SELECT name, geonameid, 10,country, admin1, admin2, admin3, admin4, TRUE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE fclass = 'P';

INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level0, level1, level2, level3,  level4, main, relevance)
SELECT asciiname, geonameid, 10,country, admin1, admin2, admin3, admin4, FALSE, population
FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@geonames`
WHERE fclass = 'P';

-- alternate names
INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, level1, level2, level3,  level4, main, preferred, language, relevance)
  SELECT a.name, g.geoid, g.level, g.level_id, g.level0, g.level1, g.level2, g.level3, g.level4, FALSE, a.isPreferredName, a.isolanguage, g.relevance
  FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@alternatenames` a
  JOIN `@@BQ_PREFIX@@carto.names` g
  ON (a.geonameid = g.geoid)
  WHERE g.main
  AND (NOT a.isColloquial OR a.isColloquial iS NULL) AND a.to IS NULL AND (a.isolanguage NOT IN ('post','iata','icao','faac','fr_1793','link','wkdt')); -- 'abbr' ?

-- country ISO codes
INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, main, relevance, language)
  SELECT c.iso_alpha2, c.geonameid, 0, c.iso_alpha2, c.iso_alpha2, FALSE, population, 'abbr'
  FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@countryinfo` c;
INSERT INTO `@@BQ_PREFIX@@carto.names`(name, geoid, level, level_id, level0, main, relevance, language)
  SELECT c.iso_alpha3, c.geonameid, 0, c.iso_alpha2, c.iso_alpha2, FALSE, population, 'abbr'
  FROM `@@BQ_PREFIX@@carto.@@GEONAMES_PREFIX@@countryinfo` c;

-- clean up NULL names
DELETE FROM `@@BQ_PREFIX@@carto.names` WHERE name IS NULL;

-- TODO: fix chicken-egg problem: __NAME_CODE is in geocoding module which requires these tables
UPDATE `@@BQ_PREFIX@@carto.names`
SET code = `@@BQ_PREFIX@@carto.__NAME_CODE`(name) WHERE TRUE;

-- Special NULL registers to help matching NULL country/admin
INSERT INTO `@@BQ_PREFIX@@carto.names`(code, name, geoid, level, level_id, level0, main, relevance)
VALUES (NULL, NULL, NULL, 0, NULL, NULL, FALSE, 0);
INSERT INTO `@@BQ_PREFIX@@carto.names`(code, name, geoid, level, level_id, level0, level1, main, relevance)
VALUES (NULL, NULL, NULL, 1, NULL, NULL, NULL, FALSE, 0);

-- Set release date
UPDATE `@@BQ_PREFIX@@carto.names`
 SET do_date = CAST(CONCAT(SUBSTR('@@GEONAMES_RELEASE@@', 1, 4), '-', SUBSTR('@@GEONAMES_RELEASE@@', 5, 2), '-01') AS TIMESTAMP)
 WHERE TRUE;
