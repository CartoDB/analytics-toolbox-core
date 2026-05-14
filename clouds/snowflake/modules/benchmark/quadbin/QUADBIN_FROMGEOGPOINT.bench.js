// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_FROMGEOGPOINT',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.QUADBIN_FROMGEOGPOINT(t.\${geom_column}, \${resolution}) AS result
FROM \${source_table} t`
});