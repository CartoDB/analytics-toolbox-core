---------------------------------
-- Copyright (C) 2025 CARTO
---------------------------------

/*
Grants EXECUTE permission on all Analytics Toolbox functions and procedures
to a specified role or user.

Oracle lacks a "GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA X TO role Y" command,
so this helper procedure automates the granting process.

Usage:
    -- Grant to a role (recommended)
    CREATE ROLE carto_analytics_user;
    CALL @@ORA_SCHEMA@@.GRANT_CARTO_ACCESS('carto_analytics_user');
    GRANT carto_analytics_user TO app_user;

    -- Grant to a specific user
    CALL @@ORA_SCHEMA@@.GRANT_CARTO_ACCESS('app_user');

    -- Revoke existing grants first, then re-grant
    CALL @@ORA_SCHEMA@@.GRANT_CARTO_ACCESS('carto_analytics_user', 'TRUE');

Parameters:
    p_grantee        - Role or username to grant permissions to
    p_revoke_first   - 'TRUE' to revoke existing grants first, 'FALSE' otherwise (default: 'FALSE')

Notes:
    - Grants EXECUTE permission on all PROCEDURES and FUNCTIONS in @@ORA_SCHEMA@@
    - Excludes GRANT_CARTO_ACCESS itself (users don't need to grant permissions)
    - Uses dynamic SQL to iterate through all AT objects
    - Follows Oracle best practices for role-based access control
    - Requires ADMIN or sufficient privileges to grant permissions
*/

CREATE OR REPLACE PROCEDURE @@ORA_SCHEMA@@.GRANT_CARTO_ACCESS(
    p_grantee VARCHAR2,
    p_revoke_first VARCHAR2 DEFAULT 'FALSE'
)
AUTHID DEFINER  -- Runs with definer privileges (needed to grant permissions)
IS
    v_grant_count NUMBER := 0;
    v_revoke_count NUMBER := 0;
    v_error_count NUMBER := 0;
    v_sql VARCHAR2(500);
    v_revoke BOOLEAN := (UPPER(p_revoke_first) = 'TRUE');
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Granting Analytics Toolbox Access ===');
    DBMS_OUTPUT.PUT_LINE('Schema: @@ORA_SCHEMA@@');
    DBMS_OUTPUT.PUT_LINE('Grantee: ' || p_grantee);
    DBMS_OUTPUT.PUT_LINE('');

    -- Revoke existing grants if requested
    IF v_revoke THEN
        DBMS_OUTPUT.PUT_LINE('Revoking existing grants...');
        FOR obj IN (
            SELECT table_name
            FROM dba_tab_privs
            WHERE grantee = UPPER(p_grantee)
              AND owner = '@@ORA_SCHEMA@@'
              AND privilege = 'EXECUTE'
        ) LOOP
            BEGIN
                v_sql := 'REVOKE EXECUTE ON @@ORA_SCHEMA@@.' || obj.table_name || ' FROM ' || p_grantee;
                EXECUTE IMMEDIATE v_sql;
                v_revoke_count := v_revoke_count + 1;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('  [WARNING] Failed to revoke ' || obj.table_name || ': ' || SQLERRM);
            END;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Revoked ' || v_revoke_count || ' grants');
        DBMS_OUTPUT.PUT_LINE('');
    END IF;

    -- Grant EXECUTE on all schema procedures and functions
    DBMS_OUTPUT.PUT_LINE('Granting EXECUTE on @@ORA_SCHEMA@@ objects...');
    FOR obj IN (
        SELECT object_name, object_type
        FROM all_objects
        WHERE owner = '@@ORA_SCHEMA@@'
          AND object_type IN ('PROCEDURE', 'FUNCTION')
          AND status = 'VALID'
          AND object_name != 'GRANT_CARTO_ACCESS'  -- Don't grant on this helper itself
        ORDER BY object_type, object_name
    ) LOOP
        BEGIN
            v_sql := 'GRANT EXECUTE ON @@ORA_SCHEMA@@.' || obj.object_name || ' TO ' || p_grantee;
            EXECUTE IMMEDIATE v_sql;
            v_grant_count := v_grant_count + 1;
            DBMS_OUTPUT.PUT_LINE('  [OK] ' || RPAD(obj.object_type, 10) || ' ' || obj.object_name);
        EXCEPTION
            WHEN OTHERS THEN
                v_error_count := v_error_count + 1;
                DBMS_OUTPUT.PUT_LINE('  [ERROR] ' || obj.object_name || ': ' || SQLERRM);
        END;
    END LOOP;

    -- Summary
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== Summary ===');
    DBMS_OUTPUT.PUT_LINE('Total grants: ' || v_grant_count);
    IF v_error_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Errors: ' || v_error_count);
    END IF;

    IF v_grant_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('[WARNING] No Analytics Toolbox objects found. Has the toolbox been deployed?');
    END IF;
END GRANT_CARTO_ACCESS;
/
