CREATE OR REPLACE PROCEDURE `@@BQ_PREFIX@@.carto.DROP_FUNCTIONS`()
BEGIN
    FOR record IN
    (SELECT CONCAT('DROP ', routine_type, ' `', specific_catalog, '.', specific_schema, '.', specific_name,'`;') as drop_command from `@@BQ_PREFIX@@.carto.INFORMATION_SCHEMA.ROUTINES`)
    DO
        EXECUTE IMMEDIATE record.drop_command;
    END FOR;
END;

CALL `@@BQ_PREFIX@@.carto.DROP_FUNCTIONS`();