----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE @@PG_SCHEMA@@.QUADBIN_POLYFILL_TABLE(
    input_query TEXT,
    resolution INT,
    mode TEXT,
    output_table TEXT
)
LANGUAGE plpgsql
AS $BODY$
DECLARE
    extra_columns TEXT;
    safe_output_table TEXT;
BEGIN
    -- Sanitize the output identifier: parse_ident validates each part (and
    -- rejects injection attempts) and quote_ident re-quotes it safely.
    SELECT STRING_AGG(QUOTE_IDENT(part), '.' ORDER BY ord)
    INTO safe_output_table
    FROM UNNEST(PARSE_IDENT(output_table)) WITH ORDINALITY AS t(part, ord);

    -- Materialize the input into a temp table so its columns can be
    -- introspected and every attribute except `geom` carried through into the
    -- output table.
    DROP TABLE IF EXISTS __quadbin_polyfill_table_input;
    EXECUTE FORMAT(
        'CREATE TEMP TABLE __quadbin_polyfill_table_input AS %s', input_query
    );

    SELECT STRING_AGG(
        'i.' || QUOTE_IDENT(column_name), ', ' ORDER BY ordinal_position
    )
    INTO extra_columns
    FROM information_schema.columns
    WHERE table_schema LIKE 'pg_temp%'
        AND table_name = '__quadbin_polyfill_table_input'
        AND column_name NOT IN ('geom', 'quadbin');

    EXECUTE FORMAT(
        'CREATE TABLE %s AS
        SELECT __cell AS quadbin%s
        FROM __quadbin_polyfill_table_input AS i,
            UNNEST(@@PG_SCHEMA@@.QUADBIN_POLYFILL(i.geom, %s, %L)) AS __cell',
        safe_output_table,
        CASE WHEN extra_columns IS NULL THEN '' ELSE ', ' || extra_columns END,
        resolution,
        mode
    );

    DROP TABLE IF EXISTS __quadbin_polyfill_table_input;
END;
$BODY$;
