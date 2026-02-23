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
    SELECT @@ORA_SCHEMA@@.@@ORA_VERSION_FUNCTION@@() FROM DUAL;

Cross-Schema Access:
    Requires GRANT EXECUTE permission for users in different schemas:
    GRANT EXECUTE ON @@ORA_SCHEMA@@.@@ORA_VERSION_FUNCTION@@ TO app_user;

Example:
    -- Same schema
    SELECT @@ORA_VERSION_FUNCTION@@() FROM DUAL;

    -- Cross-schema
    SELECT @@ORA_SCHEMA@@.@@ORA_VERSION_FUNCTION@@() FROM DUAL;
*/

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.@@ORA_VERSION_FUNCTION@@
RETURN VARCHAR2
IS
BEGIN
    RETURN '@@ORA_PACKAGE_VERSION@@';
END @@ORA_VERSION_FUNCTION@@;
/
