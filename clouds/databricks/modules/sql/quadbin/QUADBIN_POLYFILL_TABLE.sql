----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE PROCEDURE @@DB_SCHEMA@@.QUADBIN_POLYFILL_TABLE
(
    input_query STRING,
    resolution INT,
    mode STRING,
    output_table STRING
)
SQL SECURITY INVOKER
BEGIN
    -- NOTE: the `mode` parameter is accepted for forward compatibility. There
    -- is no mode-aware QUADBIN_POLYFILL yet, so the native coverage produced by
    -- QUADBIN_POLYFILL is used regardless of the requested `mode`. Full
    -- center/intersects/contains support will arrive with QUADBIN_POLYFILL_MODE.
    EXECUTE IMMEDIATE FORMAT_STRING(
        "CREATE OR REPLACE TABLE %s AS (
            WITH __input AS (
                %s
            ),
            __cells AS (
                SELECT
                    @@DB_SCHEMA@@.QUADBIN_POLYFILL(geom, %d) AS __quadbins,
                    __input.* EXCEPT (geom)
                FROM __input
            )
            SELECT __cell AS quadbin, __cells.* EXCEPT (__quadbins)
            FROM __cells
            LATERAL VIEW EXPLODE(__quadbins) t AS __cell
        )",
        output_table,
        input_query,
        resolution
    );
END;
