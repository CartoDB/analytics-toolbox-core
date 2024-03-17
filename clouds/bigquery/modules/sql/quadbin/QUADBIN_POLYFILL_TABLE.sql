---------------------------------
-- Copyright (C) 2023-2024 CARTO
---------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_QUERY`
(
    input_query STRING,
    resolution INT64,
    mode STRING,
    output_table STRING
)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library = ["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!['center', 'intersects', 'contains'].includes(mode)) {
        throw Error('Invalid mode, should be center, intersects, or contains.')
    }

    if (resolution < 0 || resolution > 26) {
        throw Error('Invalid resolution, should be between 0 and 26.')
    }

    return lib.quadbin.polyfillQuery(input_query, resolution, mode, output_table, '@@BQ_DATASET@@')
""";

CREATE OR REPLACE PROCEDURE `@@BQ_DATASET@@.QUADBIN_POLYFILL_TABLE`
(
    input_query STRING,
    resolution INT64,
    mode STRING,
    output_table STRING
)
BEGIN
    DECLARE polyfill_query STRING;

    -- Check if the destination tileset already exists
    CALL `@@BQ_DATASET@@.__CHECK_TABLE`(output_table);

    SET polyfill_query = `@@BQ_DATASET@@.__QUADBIN_POLYFILL_QUERY`(
        input_query,
        resolution,
        mode,
        output_table
    );

    EXECUTE IMMEDIATE polyfill_query;
END;
