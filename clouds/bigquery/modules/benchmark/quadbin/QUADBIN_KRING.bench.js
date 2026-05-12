// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_KRING',
    sql: 'CREATE OR REPLACE TABLE `${output_table}` AS SELECT t.${quadbin_column} AS input, `@@BQ_DATASET@@.QUADBIN_KRING`(t.${quadbin_column}, ${size}) AS cells FROM ${source_table} t'
});