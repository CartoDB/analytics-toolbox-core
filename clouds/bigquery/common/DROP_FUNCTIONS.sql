---------------------------------
-- Copyright (C) 2021-2022 CARTO
---------------------------------

CREATE OR REPLACE PROCEDURE `@@BQ_DATASET@@.DROP_FUNCTIONS`()
BEGIN
    FOR record IN
    (SELECT CONCAT('DROP ', routine_type, ' `', specific_catalog, '.', specific_schema, '.', specific_name,'`;') as drop_command from `@@BQ_DATASET@@.INFORMATION_SCHEMA.ROUTINES`)
    DO
        EXECUTE IMMEDIATE record.drop_command;
    END FOR;
END;

CALL `@@BQ_DATASET@@.DROP_FUNCTIONS`();
