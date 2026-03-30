----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE `@@BQ_DATASET@@.TABLE_FROM_GEOJSON`
(
    geojson STRING,
    destination STRING
)
BEGIN
    DECLARE prop_keys ARRAY<STRING>;
    DECLARE col_selects STRING DEFAULT '';
    DECLARE create_sql STRING;
    DECLARE i INT64 DEFAULT 0;
    DECLARE prop_key STRING;

    -- Discover property keys from all features
    SET prop_keys = (
        SELECT ARRAY_AGG(DISTINCT key ORDER BY key)
        FROM UNNEST(`@@BQ_DATASET@@.__GEOJSON_PARSE_FEATURES`(geojson)) AS feature,
             UNNEST(IFNULL(JSON_KEYS(JSON_QUERY(feature.properties, '$')), [])) AS key
    );

    -- Build select expressions for properties
    WHILE i < ARRAY_LENGTH(IFNULL(prop_keys, []))
    DO
        SET prop_key = prop_keys[OFFSET(i)];
        SET col_selects = CONCAT(
            col_selects,
            'JSON_VALUE(feature.properties, ''$.', prop_key, ''') AS ', prop_key, ', '
        );
        SET i = i + 1;
    END WHILE;

    -- Add geom column
    SET col_selects = CONCAT(col_selects, 'ST_GEOGFROMGEOJSON(feature.geom) AS geom');

    -- Build and execute CREATE TABLE
    SET create_sql = CONCAT(
        'CREATE OR REPLACE TABLE `', destination, '` AS ',
        'SELECT ', col_selects,
        ' FROM UNNEST(`@@BQ_DATASET@@.__GEOJSON_PARSE_FEATURES`(''',
        REPLACE(geojson, '''', '\\'''),
        ''')) AS feature'
    );

    EXECUTE IMMEDIATE create_sql;
END;
