----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE @@PG_SCHEMA@@.TABLE_FROM_GEOJSON
(
    geojson TEXT,
    destination TEXT
)
LANGUAGE plpgsql
AS $body$
DECLARE
    geojson_type TEXT;
    prop_keys TEXT[];
    col_defs TEXT DEFAULT '';
    col_selects TEXT DEFAULT '';
    create_sql TEXT;
    prop_key TEXT;
BEGIN
    -- Determine type
    geojson_type := geojson::json->>'type';

    -- Extract property keys from all features
    IF geojson_type = 'FeatureCollection' THEN
        SELECT ARRAY_AGG(DISTINCT key)
        INTO prop_keys
        FROM json_array_elements(geojson::json->'features') AS feature,
             json_object_keys(feature->'properties') AS key;
    ELSIF geojson_type = 'Feature' THEN
        SELECT ARRAY_AGG(key)
        INTO prop_keys
        FROM json_object_keys(geojson::json->'properties') AS key;
    ELSE
        prop_keys := ARRAY[]::TEXT[];
    END IF;

    -- Build column definitions and select expressions
    IF prop_keys IS NOT NULL THEN
        FOR i IN 1..ARRAY_LENGTH(prop_keys, 1)
        LOOP
            prop_key := prop_keys[i];
            col_defs := col_defs || prop_key || ' TEXT, ';
            col_selects := col_selects ||
                '(feature->>''properties'')::json->>''' || prop_key || ''' AS ' || prop_key || ', ';
        END LOOP;
    END IF;

    -- Add geom column
    col_defs := col_defs || 'geom GEOMETRY';
    col_selects := col_selects || 'ST_GeomFromGeoJSON(feature->>''geometry'') AS geom';

    -- Build and execute CREATE TABLE
    IF geojson_type = 'FeatureCollection' THEN
        create_sql := 'CREATE TABLE ' || destination || ' AS ' ||
            'SELECT ' || col_selects ||
            ' FROM json_array_elements(''' ||
            REPLACE(geojson, '''', '''''') ||
            '''::json->''features'') AS feature';
    ELSIF geojson_type = 'Feature' THEN
        create_sql := 'CREATE TABLE ' || destination || ' AS ' ||
            'SELECT ' ||
            REPLACE(col_selects, 'feature->>''', '''' || REPLACE(geojson, '''', '''''') || '''::json->>''') ||
            ' FROM (SELECT 1) AS dummy';
    ELSE
        create_sql := 'CREATE TABLE ' || destination || ' AS ' ||
            'SELECT ST_GeomFromGeoJSON(''' ||
            REPLACE(geojson, '''', '''''') ||
            ''') AS geom';
    END IF;

    EXECUTE create_sql;
END;
$body$;
