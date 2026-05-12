// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_KRING_DISTANCES',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT t.\${quadbin_column} AS input, @@SF_SCHEMA@@.QUADBIN_KRING_DISTANCES(t.\${quadbin_column}, \${size}) AS kring
FROM \${source_table} t`
});