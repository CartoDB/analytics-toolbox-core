// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_DISTANCE',
    sql: 'CREATE OR REPLACE TABLE `${output_table}` AS SELECT `@@BQ_DATASET@@.H3_DISTANCE`(t.${h3_column}, t.${h3_column}) AS result FROM ${source_table} t'
});