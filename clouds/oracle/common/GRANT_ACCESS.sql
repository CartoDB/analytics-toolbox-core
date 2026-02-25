----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

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
