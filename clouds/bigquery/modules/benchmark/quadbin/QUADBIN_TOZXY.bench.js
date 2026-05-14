// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_TOZXY',
    sql: 'CREATE OR REPLACE TABLE `${output_table}` AS SELECT `@@BQ_DATASET@@.QUADBIN_TOZXY`(t.${quadbin_column}) AS zxy FROM ${source_table} t'
});