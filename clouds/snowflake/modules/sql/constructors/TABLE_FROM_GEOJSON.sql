----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE @@SF_SCHEMA@@.TABLE_FROM_GEOJSON
(
    GEOJSON VARCHAR,
    DESTINATION VARCHAR
)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS $$
    DECLARE
        prop_keys ARRAY;
        col_selects VARCHAR DEFAULT '';
        create_sql VARCHAR;
        i INTEGER DEFAULT 0;
        prop_key VARCHAR;
    BEGIN
        -- Discover property keys from all features
        prop_keys := (
            SELECT ARRAY_AGG(DISTINCT f.key)
            FROM TABLE(@@SF_SCHEMA@@.__GEOJSON_PARSE_FEATURES(:GEOJSON)) AS feat,
                 TABLE(FLATTEN(PARSE_JSON(feat.PROPERTIES))) AS f
        );

        -- Build select expressions for properties
        WHILE (i < ARRAY_SIZE(IFNULL(prop_keys, ARRAY_CONSTRUCT())))
        DO
            prop_key := prop_keys[i]::STRING;
            col_selects := col_selects ||
                'PARSE_JSON(feat.PROPERTIES):' || prop_key || '::STRING AS ' || prop_key || ', ';
            i := i + 1;
        END WHILE;

        -- Add geom column
        col_selects := col_selects || 'TO_GEOGRAPHY(feat.GEOM) AS geom';

        -- Build and execute CREATE TABLE
        create_sql := 'CREATE OR REPLACE TABLE ' || DESTINATION || ' AS ' ||
            'SELECT ' || col_selects ||
            ' FROM TABLE(@@SF_SCHEMA@@.__GEOJSON_PARSE_FEATURES(''' ||
            REPLACE(GEOJSON, '''', '''''') ||
            ''')) AS feat';

        EXECUTE IMMEDIATE create_sql;
        RETURN 'Table created: ' || DESTINATION;
    END;
$$;
