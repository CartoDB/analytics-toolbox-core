// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_DISTANCE',
    sql: 'CREATE OR REPLACE TABLE `${output_table}` AS SELECT `@@BQ_DATASET@@.QUADBIN_DISTANCE`(t.${quadbin_column}, t.${quadbin_column}) AS result FROM ${source_table} t'
});