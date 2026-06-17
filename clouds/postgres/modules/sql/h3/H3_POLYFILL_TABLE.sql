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
    safe_output_table TEXT;
BEGIN
    -- Sanitize the output identifier: parse_ident validates each part (and
    -- rejects injection attempts) and quote_ident re-quotes it safely.
    SELECT STRING_AGG(QUOTE_IDENT(part), '.' ORDER BY ord)
    INTO safe_output_table
    FROM UNNEST(PARSE_IDENT(output_table)) WITH ORDINALITY AS t(part, ord);

    -- Every input column is carried through; `geom` is dropped from the
    -- output afterwards.
    EXECUTE FORMAT(
        'CREATE TABLE %s AS
        SELECT __cell AS h3, i.*
        FROM (%s) AS i,
            UNNEST(@@PG_SCHEMA@@.H3_POLYFILL(i.geom, %s, %L)) AS __cell',
        safe_output_table,
        input_query,
        resolution,
        mode
    );
    EXECUTE FORMAT('ALTER TABLE %s DROP COLUMN geom', safe_output_table);
END;
$BODY$;
