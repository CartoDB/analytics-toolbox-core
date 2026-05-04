----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE @@ORA_SCHEMA@@.H3_POLYFILL_TABLE
(
    input_query VARCHAR2,
    resolution NUMBER,
    polyfill_mode VARCHAR2,
    output_table VARCHAR2
)
IS
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;

    v_mode VARCHAR2(20);
    v_res PLS_INTEGER;
    v_sql CLOB;
    v_schema VARCHAR2(128);
    v_safe_table VARCHAR2(257);
BEGIN
    -- NULL-on-invalid: silently no-op for invalid mode/resolution/inputs.
    IF input_query IS NULL OR resolution IS NULL
       OR polyfill_mode IS NULL OR output_table IS NULL THEN
        RETURN;
    END IF;

    v_mode := LOWER(polyfill_mode);
    IF v_mode NOT IN ('center', 'intersects', 'contains') THEN
        RETURN;
    END IF;

    v_res := TRUNC(resolution);
    IF v_res < MIN_RESOLUTION OR v_res > MAX_RESOLUTION THEN
        RETURN;
    END IF;

    -- Sanitize the output identifier (rejects malicious table names)
    v_safe_table := DBMS_ASSERT.QUALIFIED_SQL_NAME(output_table);

    -- Resolve schema for the pipelined function reference
    IF INSTR(v_safe_table, '.') > 0 THEN
        v_schema := SUBSTR(v_safe_table, 1, INSTR(v_safe_table, '.') - 1);
    ELSE
        v_schema := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
    END IF;

    -- CTAS that consumes H3_POLYFILL_MODE as a pipelined nested table.
    -- The input_query must expose a column named GEOM of type SDO_GEOMETRY.
    -- Mode and resolution can't be bound as parameters here — Oracle
    -- raises ORA-22905 when bind variables appear inside a correlated
    -- TABLE() expression in a CTAS. They are safe to inline because we
    -- validated v_mode against a fixed allowlist and TRUNC'd v_res into
    -- a small integer above. The output table name and schema are
    -- validated identifiers (DBMS_ASSERT.QUALIFIED_SQL_NAME).
    v_sql := 'CREATE TABLE ' || v_safe_table || ' AS
        SELECT t.COLUMN_VALUE AS h3, i.*
          FROM (' || input_query || ') i,
               TABLE(' || v_schema || '.H3_POLYFILL_MODE(
                   i.geom, ' || v_res || ', ''' || v_mode || '''
               )) t';

    EXECUTE IMMEDIATE v_sql;
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        NULL;
END H3_POLYFILL_TABLE;
/
