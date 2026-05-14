// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_POLYFILL',
    sql: 'CREATE OR REPLACE TABLE `${output_table}` AS SELECT `@@BQ_DATASET@@.QUADBIN_POLYFILL`(t.${geom_column}, ${resolution}) AS cells FROM ${source_table} t'
});