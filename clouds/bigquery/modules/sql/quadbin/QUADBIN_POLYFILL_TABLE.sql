----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

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
AS """
    if (!['center', 'intersects', 'contains'].includes(mode)) {
        throw Error('Invalid mode, should be center, intersects, or contains.')
    }

    if (resolution < 0 || resolution > 26) {
        throw Error('Invalid resolution, should be between 0 and 26.')
    }

    output_table = output_table.replace(/`/g, '')

    return 'CREATE TABLE `' + output_table + '` CLUSTER BY (quadbin) AS\\n' +
        'WITH __input AS (' + input_query + ')\\n' +
        'SELECT quadbin, i.* FROM __input AS i,\\n' +
        'UNNEST(`@@BQ_DATASET@@.QUADBIN_POLYFILL_MODE`(geom,' + resolution + ',\\'' + mode + '\\')) AS quadbin;'
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
