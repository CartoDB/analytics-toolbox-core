----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE @@ORA_SCHEMA@@.INTERNAL_DROP_FUNCTIONS
IS
    v_drop_command VARCHAR2(500);
    v_object_count NUMBER := 0;
    v_success_count NUMBER := 0;
    v_error_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Dropping Analytics Toolbox Functions and Procedures ===');
    DBMS_OUTPUT.PUT_LINE('Schema: @@ORA_SCHEMA@@');
    DBMS_OUTPUT.PUT_LINE('');

    -- Loop through all functions and procedures in the schema
    -- Note: Includes INTERNAL_DROP_FUNCTIONS itself (will be dropped during loop)
    FOR rec IN (
        SELECT object_name, object_type
        FROM all_objects
        WHERE owner = '@@ORA_SCHEMA@@'
          AND object_type IN ('FUNCTION', 'PROCEDURE')
          -- Future: Uncomment the following line to only drop CARTO-prefixed objects
          -- AND object_name LIKE 'CARTO_%'
        ORDER BY
          -- Drop procedures before functions (in case of dependencies)
          CASE object_type WHEN 'PROCEDURE' THEN 1 ELSE 2 END,
          object_name
    ) LOOP
        v_object_count := v_object_count + 1;

        BEGIN
            v_drop_command := 'DROP ' || rec.object_type || ' @@ORA_SCHEMA@@.' || rec.object_name;
            EXECUTE IMMEDIATE v_drop_command;

            v_success_count := v_success_count + 1;
            DBMS_OUTPUT.PUT_LINE('[OK] Dropped ' || rec.object_type || ': ' || rec.object_name);

        EXCEPTION
            WHEN OTHERS THEN
                v_error_count := v_error_count + 1;
                DBMS_OUTPUT.PUT_LINE('[ERROR] Failed to drop ' || rec.object_type || ': ' || rec.object_name);
                DBMS_OUTPUT.PUT_LINE('  Error: ' || SUBSTR(SQLERRM, 1, 200));
        END;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== Summary ===');
    DBMS_OUTPUT.PUT_LINE('Total objects found: ' || v_object_count);
    DBMS_OUTPUT.PUT_LINE('Successfully dropped: ' || v_success_count);
    DBMS_OUTPUT.PUT_LINE('Errors: ' || v_error_count);

    IF v_object_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('No Analytics Toolbox objects found in schema @@ORA_SCHEMA@@');
    END IF;
END INTERNAL_DROP_FUNCTIONS;
/

BEGIN
    @@ORA_SCHEMA@@.INTERNAL_DROP_FUNCTIONS;
END;
/
