----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE @@DB_SCHEMA@@.DROP_FUNCTIONS()
SQL SECURITY INVOKER
BEGIN
    FOR record AS
        SELECT CONCAT('DROP ', routine_type, ' `', routine_catalog, '`.`', routine_schema, '`.`', routine_name,'`;') AS drop_command
        FROM `@@DB_CATALOG@@`.INFORMATION_SCHEMA.ROUTINES
        WHERE routine_schema = '@@DB_UNQUALIFIED_SCHEMA@@'
    DO
        EXECUTE IMMEDIATE record.drop_command;
    END FOR;
END;

CALL @@DB_SCHEMA@@.DROP_FUNCTIONS();
