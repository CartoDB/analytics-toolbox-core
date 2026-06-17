--------------------------------
-- Copyright (C) 2026 CARTO
--------------------------------

CREATE OR REPLACE PROCEDURE @@SF_SCHEMA@@.QUADBIN_POLYFILL_TABLE
(
    input_query STRING,
    resolution INT,
    mode STRING,
    output_table STRING
)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS $$
BEGIN
    -- NOTE: the `mode` parameter is accepted for forward compatibility. There
    -- is no mode-aware QUADBIN_POLYFILL yet, so the native coverage produced by
    -- QUADBIN_POLYFILL is used regardless of the requested `mode`. Full
    -- center/intersects/contains support will arrive with QUADBIN_POLYFILL_MODE.
    EXECUTE IMMEDIATE '
        CREATE OR REPLACE TABLE ' || output_table || ' CLUSTER BY (QUADBIN) AS
        WITH __input AS ( ' || input_query || ' )
        SELECT CAST(cell.value AS BIGINT) AS quadbin, i.* EXCLUDE(geom)
        FROM __input AS i, TABLE(FLATTEN(@@SF_SCHEMA@@.QUADBIN_POLYFILL(geom, ' || resolution || '))) AS cell;
    ';

    RETURN 'Quadbin Polyfill result added in table ' || output_table;
END;
$$;
