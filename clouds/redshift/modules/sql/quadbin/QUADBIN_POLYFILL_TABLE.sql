--------------------------------
-- Copyright (C) 2026 CARTO
--------------------------------

CREATE OR REPLACE PROCEDURE @@RS_SCHEMA@@.QUADBIN_POLYFILL_TABLE
(
    input_query VARCHAR(MAX),
    resolution INT,
    mode VARCHAR(MAX),
    output_table VARCHAR(MAX)
)
AS $$
DECLARE
    passthrough_inner VARCHAR(MAX);
    passthrough_outer VARCHAR(MAX);
    output_first VARCHAR(MAX);
    output_second VARCHAR(MAX);
    output_third VARCHAR(MAX);
    output_fourth VARCHAR(MAX);
BEGIN
    -- The `mode` parameter is accepted for forward compatibility. There is no
    -- mode-aware QUADBIN_POLYFILL yet, so the native coverage produced by
    -- QUADBIN_POLYFILL is used regardless of the requested `mode`. Full
    -- center/intersects/contains support will arrive with QUADBIN_POLYFILL_MODE.

    -- Validate the output table name
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 1)' INTO output_first;
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 2)' INTO output_second;
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 3)' INTO output_third;
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 4)' INTO output_fourth;
    IF output_first = '' OR output_second = '' OR output_fourth != ''
    THEN
        RAISE EXCEPTION 'Invalid output table name. It must have the form [DATABASE.]SCHEMA.TABLE';
    END IF;

    -- Materialize the input so its columns can be introspected and every
    -- attribute except `geom` carried through into the output table.
    EXECUTE 'DROP TABLE IF EXISTS __quadbin_polyfill_input';
    EXECUTE 'CREATE TEMP TABLE __quadbin_polyfill_input AS ' || input_query;

    SELECT
        LISTAGG(QUOTE_IDENT("column"), ', ') WITHIN GROUP (ORDER BY "column"),
        LISTAGG('p.' || QUOTE_IDENT("column"), ', ') WITHIN GROUP (ORDER BY "column")
    INTO passthrough_inner, passthrough_outer
    FROM pg_table_def
    WHERE tablename = '__quadbin_polyfill_input'
        AND "column" <> 'geom';

    -- Unnest the QUADBIN_POLYFILL SUPER array into one row per cell. The array
    -- is produced as a subquery column, then navigated with PartiQL.
    EXECUTE 'CREATE TABLE ' || output_table || ' AS
        SELECT __cell::BIGINT AS quadbin' || NVL(', ' || passthrough_outer, '') || '
        FROM (
            SELECT @@RS_SCHEMA@@.QUADBIN_POLYFILL(geom, ' || resolution || ') AS __quadbins'
            || NVL(', ' || passthrough_inner, '') || '
            FROM __quadbin_polyfill_input
        ) AS p, p.__quadbins AS __cell';

    EXECUTE 'DROP TABLE IF EXISTS __quadbin_polyfill_input';
END;
$$ LANGUAGE plpgsql;
