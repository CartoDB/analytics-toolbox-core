// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_POLYFILL',
    sql: 'CREATE OR REPLACE TABLE `${output_table}` AS SELECT `@@BQ_DATASET@@.H3_POLYFILL`(t.${geom_column}, ${resolution}) AS cells FROM ${source_table} t'
});