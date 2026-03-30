----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE @@RS_SCHEMA@@.TABLE_FROM_GEOJSON
(
    geojson INOUT VARCHAR(MAX),
    destination VARCHAR(MAX)
)
AS $$
    DECLARE
        geojson_type VARCHAR(MAX);
        num_features INTEGER;
        features_json VARCHAR(MAX);
        feature_json VARCHAR(MAX);
        properties_json VARCHAR(MAX);
        geometry_json VARCHAR(MAX);
        col_defs VARCHAR(MAX) DEFAULT '';
        insert_sql VARCHAR(MAX);
        prop_key VARCHAR(MAX);
        prop_value VARCHAR(MAX);
        i INTEGER;
    BEGIN
        geojson_type := JSON_EXTRACT_PATH_TEXT(geojson, 'type');

        IF geojson_type = 'FeatureCollection' THEN
            features_json := JSON_EXTRACT_PATH_TEXT(geojson, 'features');
            num_features := JSON_ARRAY_LENGTH(features_json);
        ELSIF geojson_type = 'Feature' THEN
            num_features := 1;
        ELSE
            -- Bare geometry
            EXECUTE 'CREATE TABLE ' || destination ||
                ' AS SELECT ST_GEOMFROMGEOJSON(''' ||
                REPLACE(geojson, '''', '''''') || ''') AS geom';
            geojson := 'Table created: ' || destination;
            RETURN;
        END IF;

        -- Discover property keys using a temp table + SUPER type
        -- Parse the first feature's properties to get column names
        CREATE TEMP TABLE __geojson_prop_discovery (key_name VARCHAR(MAX));

        IF geojson_type = 'FeatureCollection' THEN
            properties_json := JSON_EXTRACT_PATH_TEXT(
                JSON_EXTRACT_ARRAY_ELEMENT_TEXT(features_json, 0),
                'properties'
            );
        ELSE
            properties_json := JSON_EXTRACT_PATH_TEXT(geojson, 'properties');
        END IF;

        -- Use SUPER type to extract keys from properties
        EXECUTE 'INSERT INTO __geojson_prop_discovery ' ||
            'SELECT key FROM (SELECT key FROM OBJECT_KEYS(JSON_PARSE(''' ||
            REPLACE(properties_json, '''', '''''') ||
            ''')) AS t(key))';

        -- Build column definitions from discovered keys
        FOR prop_key IN SELECT key_name FROM __geojson_prop_discovery
        LOOP
            col_defs := col_defs || prop_key || ' VARCHAR(MAX), ';
        END LOOP;

        col_defs := col_defs || 'geom GEOMETRY';

        -- Create table
        EXECUTE 'CREATE TABLE ' || destination || ' (' || col_defs || ')';

        DROP TABLE __geojson_prop_discovery;

        -- Insert features
        i := 0;
        WHILE i < num_features
        LOOP
            IF geojson_type = 'FeatureCollection' THEN
                feature_json := JSON_EXTRACT_ARRAY_ELEMENT_TEXT(features_json, i);
            ELSE
                feature_json := geojson;
            END IF;

            properties_json := JSON_EXTRACT_PATH_TEXT(feature_json, 'properties');
            geometry_json := JSON_EXTRACT_PATH_TEXT(feature_json, 'geometry');

            -- Build INSERT dynamically with property values
            insert_sql := 'INSERT INTO ' || destination || ' SELECT ';

            -- Use a temp table to iterate keys in order
            CREATE TEMP TABLE __geojson_insert_keys (key_name VARCHAR(MAX));
            EXECUTE 'INSERT INTO __geojson_insert_keys ' ||
                'SELECT key FROM (SELECT key FROM OBJECT_KEYS(JSON_PARSE(''' ||
                REPLACE(properties_json, '''', '''''') ||
                ''')) AS t(key))';

            FOR prop_key IN SELECT key_name FROM __geojson_insert_keys
            LOOP
                prop_value := JSON_EXTRACT_PATH_TEXT(properties_json, prop_key);
                insert_sql := insert_sql || '''' ||
                    REPLACE(prop_value, '''', '''''') || '''::VARCHAR(MAX), ';
            END LOOP;

            DROP TABLE __geojson_insert_keys;

            insert_sql := insert_sql || 'ST_GEOMFROMGEOJSON(''' ||
                REPLACE(geometry_json, '''', '''''') || ''')';

            EXECUTE insert_sql;
            i := i + 1;
        END LOOP;

        geojson := 'Table created: ' || destination;
    END;
$$ LANGUAGE plpgsql;
