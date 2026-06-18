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
    output_first VARCHAR(MAX);
    output_second VARCHAR(MAX);
    output_third VARCHAR(MAX);
    output_fourth VARCHAR(MAX);
    safe_output_table VARCHAR(MAX);
BEGIN
    -- The `mode` parameter is accepted for forward compatibility. There is no
    -- mode-aware QUADBIN_POLYFILL yet, so the native coverage produced by
    -- QUADBIN_POLYFILL is used regardless of the requested `mode`. Full
    -- center/intersects/contains support will arrive with QUADBIN_POLYFILL_MODE.

    -- Validate and safely quote the output table name. QUOTE_LITERAL guards
    -- the validation queries and QUOTE_IDENT guards the DDL below, so the
    -- output_table value can never inject SQL.
    EXECUTE 'SELECT split_part(' || QUOTE_LITERAL(output_table) || ', ''.'', 1)'
        INTO output_first;
    EXECUTE 'SELECT split_part(' || QUOTE_LITERAL(output_table) || ', ''.'', 2)'
        INTO output_second;
    EXECUTE 'SELECT split_part(' || QUOTE_LITERAL(output_table) || ', ''.'', 3)'
        INTO output_third;
    EXECUTE 'SELECT split_part(' || QUOTE_LITERAL(output_table) || ', ''.'', 4)'
        INTO output_fourth;
    IF output_first = '' OR output_second = '' OR output_fourth != ''
    THEN
        RAISE EXCEPTION
            'Invalid output table name. It must have the form [DATABASE.]SCHEMA.TABLE';
    END IF;
    IF output_third = ''
    THEN
        safe_output_table := QUOTE_IDENT(output_first)
            || '.' || QUOTE_IDENT(output_second);
    ELSE
        safe_output_table := QUOTE_IDENT(output_first)
            || '.' || QUOTE_IDENT(output_second)
            || '.' || QUOTE_IDENT(output_third);
    END IF;

    -- Unnest the QUADBIN_POLYFILL SUPER array into one row per cell, carrying
    -- through every input column. Redshift has no `SELECT * EXCEPT`, so the
    -- helper array column and `geom` are dropped from the output afterwards.
    EXECUTE 'CREATE TABLE ' || safe_output_table || ' AS
        SELECT __cell::BIGINT AS quadbin, p.*
        FROM (
            SELECT *,
                @@RS_SCHEMA@@.QUADBIN_POLYFILL(geom, ' || resolution || ')
                    AS __quadbins
            FROM (' || input_query || ') AS __input
        ) AS p, p.__quadbins AS __cell';
    EXECUTE 'ALTER TABLE ' || safe_output_table || ' DROP COLUMN __quadbins';
    EXECUTE 'ALTER TABLE ' || safe_output_table || ' DROP COLUMN geom';
END;
$$ LANGUAGE plpgsql;
