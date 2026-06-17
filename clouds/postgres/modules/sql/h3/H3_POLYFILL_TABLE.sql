----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE @@PG_SCHEMA@@.H3_POLYFILL_TABLE(
    input_query TEXT,
    resolution INT,
    mode TEXT,
    output_table TEXT
)
LANGUAGE plpgsql
AS $BODY$
DECLARE
    extra_columns TEXT;
BEGIN
    -- Materialize the input into a temp table so its columns can be
    -- introspected and every attribute except `geom` carried through into the
    -- output table.
    DROP TABLE IF EXISTS __h3_polyfill_table_input;
    EXECUTE FORMAT(
        'CREATE TEMP TABLE __h3_polyfill_table_input AS %s', input_query
    );

    SELECT STRING_AGG(
        'i.' || QUOTE_IDENT(column_name), ', ' ORDER BY ordinal_position
    )
    INTO extra_columns
    FROM information_schema.columns
    WHERE table_schema LIKE 'pg_temp%'
        AND table_name = '__h3_polyfill_table_input'
        AND column_name <> 'geom';

    EXECUTE FORMAT(
        'CREATE TABLE %s AS
        SELECT __cell AS h3%s
        FROM __h3_polyfill_table_input AS i,
            UNNEST(@@PG_SCHEMA@@.H3_POLYFILL(i.geom, %s, %L)) AS __cell',
        output_table,
        CASE WHEN extra_columns IS NULL THEN '' ELSE ', ' || extra_columns END,
        resolution,
        mode
    );

    DROP TABLE IF EXISTS __h3_polyfill_table_input;
END;
$BODY$;
