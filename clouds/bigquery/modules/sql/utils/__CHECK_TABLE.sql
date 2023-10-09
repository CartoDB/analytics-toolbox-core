---------------------------------
-- Copyright (C) 2020-2021 CARTO
---------------------------------

CREATE OR REPLACE PROCEDURE `@@BQ_DATASET@@.__CHECK_TABLE`
(destination_table STRING)
BEGIN
    DECLARE destination_parts DEFAULT (SELECT `@@BQ_DATASET@@.__TABLENAME_SPLIT`(destination_table));
    DECLARE tables_metadata STRING;
    DECLARE table_name STRING;
    DECLARE num_tables INT64;

    IF destination_parts IS NULL OR destination_parts.table IS NULL OR destination_parts.dataset IS NULL THEN
        SELECT ERROR("The output table does not have a correct format, i.e. [projectID].dataset.tablename. Please, use a different output table name and try again.");
    END IF;

    SET table_name = destination_parts.table;
    SET tables_metadata = `@@BQ_DATASET@@.__TABLENAME_JOIN`((destination_parts.project, destination_parts.dataset, '__TABLES__'));

    EXECUTE IMMEDIATE FORMAT(
        '''
        SELECT COUNT(size_bytes)
        FROM %s
        WHERE table_id='%s'
        ''',
        tables_metadata,
        table_name
    ) INTO num_tables;

    IF num_tables > 0 THEN
        SELECT ERROR("The output table to store the tileset already exists. Please, use a different output table name and try again.");
    END IF;
END;
