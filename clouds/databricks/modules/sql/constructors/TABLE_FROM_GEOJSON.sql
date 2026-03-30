----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE @@DB_SCHEMA@@.TABLE_FROM_GEOJSON
(
    geojson STRING,
    destination STRING
)
LANGUAGE SQL
AS
BEGIN
    DECLARE geojson_type STRING;
    DECLARE prop_keys ARRAY<STRING>;
    DECLARE col_selects STRING DEFAULT '';
    DECLARE create_sql STRING;
    DECLARE i INT DEFAULT 0;
    DECLARE num_features INT;
    DECLARE prop_key STRING;

    -- Determine type
    SET geojson_type = get_json_object(geojson, '$.type');

    -- Discover property keys from all features
    -- Use MAP_KEYS on FROM_JSON to extract keys from properties
    IF geojson_type = 'FeatureCollection' THEN
        SET num_features = SIZE(FROM_JSON(
            get_json_object(geojson, '$.features'),
            'ARRAY<STRUCT<type:STRING>>'
        ));
        SET prop_keys = (
            SELECT COLLECT_SET(key)
            FROM (
                SELECT EXPLODE(
                    MAP_KEYS(
                        FROM_JSON(
                            get_json_object(
                                geojson,
                                CONCAT('$.features[', idx, '].properties')
                            ),
                            'MAP<STRING,STRING>'
                        )
                    )
                ) AS key
                FROM (SELECT EXPLODE(SEQUENCE(0, num_features - 1)) AS idx)
            )
        );
    ELSEIF geojson_type = 'Feature' THEN
        SET prop_keys = (
            SELECT COLLECT_SET(key)
            FROM (
                SELECT EXPLODE(
                    MAP_KEYS(
                        FROM_JSON(
                            get_json_object(geojson, '$.properties'),
                            'MAP<STRING,STRING>'
                        )
                    )
                ) AS key
            )
        );
    ELSE
        SET prop_keys = ARRAY();
    END IF;

    -- Build select expressions for properties
    WHILE i < SIZE(IFNULL(prop_keys, ARRAY()))
    DO
        SET prop_key = prop_keys[i];
        SET col_selects = CONCAT(col_selects,
            'get_json_object(feature, ''$.properties.', prop_key, ''') AS `', prop_key, '`, '
        );
        SET i = i + 1;
    END WHILE;

    -- Add geom column
    SET col_selects = CONCAT(col_selects, 'ST_GEOMFROMGEOJSON(get_json_object(feature, ''$.geometry'')) AS geom');

    -- Build and execute CREATE TABLE
    IF geojson_type = 'FeatureCollection' THEN
        SET create_sql = CONCAT(
            'CREATE OR REPLACE TABLE ', destination, ' AS SELECT ', col_selects,
            ' FROM (SELECT get_json_object(''',
            REPLACE(geojson, '''', '\\'''),
            ''', CONCAT(''$.features['', idx, '']'')) AS feature',
            ' FROM (SELECT EXPLODE(SEQUENCE(0, ',
            CAST(num_features - 1 AS STRING),
            ')) AS idx))'
        );
    ELSEIF geojson_type = 'Feature' THEN
        SET create_sql = CONCAT(
            'CREATE OR REPLACE TABLE ', destination, ' AS SELECT ', col_selects,
            ' FROM (SELECT ''',
            REPLACE(geojson, '''', '\\'''),
            ''' AS feature)'
        );
    ELSE
        SET create_sql = CONCAT(
            'CREATE OR REPLACE TABLE ', destination,
            ' AS SELECT ST_GEOMFROMGEOJSON(''',
            REPLACE(geojson, '''', '\\'''),
            ''') AS geom'
        );
    END IF;

    EXECUTE IMMEDIATE create_sql;
END;
