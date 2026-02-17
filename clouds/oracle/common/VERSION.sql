----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

/*
Returns the version of the Oracle Analytics Toolbox.

For core package: VERSION_CORE returns the open-source core version
For advanced package: VERSION_ADVANCED returns the premium version and is used by
cloud-native to detect Analytics Toolbox installation and validate the version
for atLocation parameter support.

Usage:
    SELECT @@ORACLE_SCHEMA@@.@@ORACLE_VERSION_FUNCTION@@() FROM DUAL;

Cross-Schema Access:
    Requires GRANT EXECUTE permission for users in different schemas:
    GRANT EXECUTE ON @@ORACLE_SCHEMA@@.@@ORACLE_VERSION_FUNCTION@@ TO app_user;

Example:
    -- Same schema
    SELECT @@ORACLE_VERSION_FUNCTION@@() FROM DUAL;

    -- Cross-schema
    SELECT @@ORACLE_SCHEMA@@.@@ORACLE_VERSION_FUNCTION@@() FROM DUAL;
*/

CREATE OR REPLACE FUNCTION @@ORACLE_SCHEMA@@.@@ORACLE_VERSION_FUNCTION@@
RETURN VARCHAR2
IS
BEGIN
    RETURN '@@ORACLE_PACKAGE_VERSION@@';
END @@ORACLE_VERSION_FUNCTION@@;
/
