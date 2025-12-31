--------------------------------
-- Copyright (C) 2022-2025 CARTO
--------------------------------

CREATE OR REPLACE PROCEDURE @@RS_SCHEMA@@.CREATE_CLUSTERKMEANS
(
    input VARCHAR(MAX),
    output_table INOUT VARCHAR(MAX),
    geom_column VARCHAR(MAX),
    number_of_clusters INT
)
AS $$
DECLARE
    input_query VARCHAR(MAX);
    table_format INTEGER;
    temp_table VARCHAR(MAX) := '';
    output_first VARCHAR(MAX);
    output_second VARCHAR(MAX);
    output_third VARCHAR(MAX);
    output_fourth VARCHAR(MAX);
    clustering VARCHAR (MAX);
    input_points VARCHAR(MAX);
BEGIN
    input_query := input;
    EXECUTE 'SELECT regexp_count(''' || input || ''', ''\\\\s'')' INTO table_format;
    IF table_format > 0
    THEN
        input_query := '(' || input || ')';
    END IF;
    -- Validate output table
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 1)' INTO output_first;
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 2)' INTO output_second;
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 3)' INTO output_third;
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 4)' INTO output_fourth;
    IF output_first = '' OR output_second = '' OR output_fourth != ''
    THEN
        output_table := 'Invalid output table name. It must have the form [DATABASE.]SCHEMA.TABLE';
        RAISE INFO 'Invalid output table name. It must have the form [DATABASE.]SCHEMA.TABLE';
        RETURN;
    END IF;

    -- Create output table with support indices
    EXECUTE 'CREATE TABLE ' || output_table || ' AS
        SELECT *,
        ROW_NUMBER() OVER() AS __carto_idx,
        NULL::INT AS cluster_id
        FROM ' || input_query;

    -- Compute clustering
    EXECUTE 'WITH input_points AS (
                SELECT __carto_idx, ST_X(' || geom_column || ')::DECIMAL(12,7) || '','' ||
                      ST_Y(' || geom_column || ')::DECIMAL(12,7) AS coordinates
                FROM ' || output_table || ' WHERE ' || geom_column || ' IS NOT NULL
            )
            SELECT ''{"_coords":['' || LISTAGG(coordinates, '','')
            WITHIN GROUP (ORDER BY __carto_idx ASC) || '']}'' FROM input_points' INTO input_points;

     EXECUTE 'SELECT @@RS_SCHEMA@@.__CLUSTERKMEANSTABLE(''' ||
           input_points || ''',' || number_of_clusters ||')' INTO clustering;

     -- Create dummy table for unnesting
    EXECUTE 'CREATE TEMP TABLE DUAL AS SELECT 0 AS DUMMY';

    -- Update table
    EXECUTE 'UPDATE ' || output_table || '
            SET cluster_id = g.c::INT
            FROM (
                SELECT c.i, c.c
                FROM (
                    SELECT JSON_PARSE(''' || clustering || ''') cluster_arr
                    FROM DUAL
                ) as cs, cs.cluster_arr as c
            ) g
            WHERE g.i = __carto_idx';

    -- Release resources and dummy table
    EXECUTE 'DROP TABLE IF EXISTS DUAL';
    EXECUTE 'ALTER TABLE ' || output_table || ' DROP COLUMN __carto_idx';

    output_table := 'Table ' || output_table || ' created with the clustering';

END;
$$ LANGUAGE plpgsql;
