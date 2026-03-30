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
    col_defs CLOB DEFAULT '';
    col_selects CLOB DEFAULT '';
    create_sql CLOB;
    insert_sql CLOB;
    num_features NUMBER;
    feature_json CLOB;
    geometry_json CLOB;
    prop_value CLOB;
BEGIN
    -- Determine type
    SELECT JSON_VALUE(geojson, '$.type') INTO geojson_type FROM DUAL;

    IF geojson_type = 'FeatureCollection' THEN
        -- Extract property keys from all features using JSON_TABLE
        FOR prop_rec IN (
            SELECT DISTINCT jt.key_name
            FROM JSON_TABLE(
                geojson, '$.features[*].properties'
                COLUMNS (
                    NESTED PATH '$.*' COLUMNS (
                        key_name VARCHAR2(128) PATH '$'
                    )
                )
            ) jt
            WHERE jt.key_name IS NOT NULL
            UNION
            SELECT DISTINCT k.column_value AS key_name
            FROM JSON_TABLE(
                geojson, '$.features[0].properties'
                COLUMNS (keys VARCHAR2(4000) FORMAT JSON PATH '$')
            ) j,
            TABLE(
                CAST(
                    (SELECT COLLECT(REGEXP_SUBSTR(REGEXP_REPLACE(j.keys, '[{}"]', ''), '[^,:]+', 1, LEVEL))
                     FROM DUAL
                     CONNECT BY LEVEL <= REGEXP_COUNT(j.keys, ',') + 1)
                    AS SYS.ODCIVARCHAR2LIST
                )
            ) k
            WHERE MOD(ROWNUM, 2) = 1
        )
        LOOP
            col_defs := col_defs || prop_rec.key_name || ' VARCHAR2(4000), ';
            col_selects := col_selects ||
                'JSON_VALUE(j.feature_json, ''$.properties.' || prop_rec.key_name || ''') AS ' ||
                prop_rec.key_name || ', ';
        END LOOP;

        -- Add geom column
        col_defs := col_defs || 'geom SDO_GEOMETRY';
        col_selects := col_selects || 'SDO_UTIL.FROM_GEOJSON(NULL, JSON_QUERY(j.feature_json, ''$.geometry'')) AS geom';

        -- Create table
        EXECUTE IMMEDIATE 'CREATE TABLE ' || destination || ' (' || col_defs || ')';

        -- Insert features using JSON_TABLE
        insert_sql := 'INSERT INTO ' || destination ||
            ' SELECT ' || col_selects ||
            ' FROM JSON_TABLE(''' || REPLACE(geojson, '''', '''''') ||
            ''', ''$.features[*]'' COLUMNS (feature_json CLOB FORMAT JSON PATH ''$'')) j';
        EXECUTE IMMEDIATE insert_sql;

    ELSIF geojson_type = 'Feature' THEN
        -- Single feature: extract properties
        FOR prop_rec IN (
            SELECT j.key_name
            FROM JSON_TABLE(
                geojson, '$.properties'
                COLUMNS (
                    NESTED PATH '$.*' COLUMNS (
                        key_name VARCHAR2(128) PATH '$'
                    )
                )
            ) j
            WHERE j.key_name IS NOT NULL
        )
        LOOP
            col_defs := col_defs || prop_rec.key_name || ' VARCHAR2(4000), ';
            col_selects := col_selects ||
                'JSON_VALUE(''' || REPLACE(geojson, '''', '''''') ||
                ''', ''$.properties.' || prop_rec.key_name || ''') AS ' ||
                prop_rec.key_name || ', ';
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
