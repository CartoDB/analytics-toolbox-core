// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_INT_TOSTRING',
    sql: 'CREATE OR REPLACE TABLE `${output_table}` AS SELECT `@@BQ_DATASET@@.H3_INT_TOSTRING`(${h3}) AS result FROM ${source_table}'
});