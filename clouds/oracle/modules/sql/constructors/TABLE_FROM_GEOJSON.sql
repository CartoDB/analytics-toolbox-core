----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE @@ORA_SCHEMA@@.TABLE_FROM_GEOJSON
(
    geojson IN CLOB,
    destination IN VARCHAR2
)
IS
    geojson_type VARCHAR2(100);
    geojson_obj JSON_OBJECT_T;
    features_arr JSON_ARRAY_T;
    feature_obj JSON_OBJECT_T;
    props_obj JSON_OBJECT_T;
    prop_keys JSON_KEY_LIST;
    col_defs CLOB DEFAULT '';
    col_selects CLOB DEFAULT '';
    insert_sql CLOB;
    all_keys JSON_KEY_LIST := JSON_KEY_LIST();
    key_exists BOOLEAN;
    i NUMBER;
    j NUMBER;
    k NUMBER;
BEGIN
    geojson_obj := JSON_OBJECT_T.PARSE(geojson);
    geojson_type := geojson_obj.get_string('type');

    IF geojson_type = 'FeatureCollection' THEN
        features_arr := geojson_obj.get_array('features');

        -- Discover all unique property keys across all features
        FOR i IN 0 .. features_arr.get_size() - 1
        LOOP
            feature_obj := JSON_OBJECT_T(features_arr.get(i));
            IF feature_obj.has('properties') THEN
                props_obj := feature_obj.get_object('properties');
                prop_keys := props_obj.get_keys();
                FOR j IN 1 .. prop_keys.COUNT
                LOOP
                    key_exists := FALSE;
                    FOR k IN 1 .. all_keys.COUNT
                    LOOP
                        IF all_keys(k) = prop_keys(j) THEN
                            key_exists := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;
                    IF NOT key_exists THEN
                        all_keys.EXTEND;
                        all_keys(all_keys.COUNT) := prop_keys(j);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;

        -- Build column definitions and select expressions
        FOR i IN 1 .. all_keys.COUNT
        LOOP
            col_defs := col_defs || all_keys(i) || ' VARCHAR2(4000), ';
            col_selects := col_selects ||
                'JSON_VALUE(j.feature_json, ''$.properties.' || all_keys(i) || ''') AS ' ||
                all_keys(i) || ', ';
        END LOOP;

        col_defs := col_defs || 'geom SDO_GEOMETRY';
        col_selects := col_selects || 'SDO_UTIL.FROM_GEOJSON(NULL, JSON_QUERY(j.feature_json, ''$.geometry'')) AS geom';

        -- Create table and insert using JSON_TABLE
        EXECUTE IMMEDIATE 'CREATE TABLE ' || destination || ' (' || col_defs || ')';

        insert_sql := 'INSERT INTO ' || destination ||
            ' SELECT ' || col_selects ||
            ' FROM JSON_TABLE(''' || REPLACE(geojson, '''', '''''') ||
            ''', ''$.features[*]'' COLUMNS (feature_json CLOB FORMAT JSON PATH ''$'')) j';
        EXECUTE IMMEDIATE insert_sql;

    ELSIF geojson_type = 'Feature' THEN
        -- Single feature
        IF geojson_obj.has('properties') THEN
            props_obj := geojson_obj.get_object('properties');
            all_keys := props_obj.get_keys();
        END IF;

        FOR i IN 1 .. all_keys.COUNT
        LOOP
            col_defs := col_defs || all_keys(i) || ' VARCHAR2(4000), ';
            col_selects := col_selects ||
                'JSON_VALUE(''' || REPLACE(geojson, '''', '''''') ||
                ''', ''$.properties.' || all_keys(i) || ''') AS ' ||
                all_keys(i) || ', ';
        END LOOP;

        col_defs := col_defs || 'geom SDO_GEOMETRY';
        col_selects := col_selects ||
            'SDO_UTIL.FROM_GEOJSON(NULL, JSON_QUERY(''' || REPLACE(geojson, '''', '''''') ||
            ''', ''$.geometry'')) AS geom';

        EXECUTE IMMEDIATE 'CREATE TABLE ' || destination || ' AS SELECT ' ||
            col_selects || ' FROM DUAL';

    ELSE
        -- Bare geometry
        EXECUTE IMMEDIATE 'CREATE TABLE ' || destination ||
            ' AS SELECT SDO_UTIL.FROM_GEOJSON(NULL, ''' ||
            REPLACE(geojson, '''', '''''') ||
            ''') AS geom FROM DUAL';
    END IF;
END;
/
