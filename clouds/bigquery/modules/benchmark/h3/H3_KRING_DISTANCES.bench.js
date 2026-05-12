// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_KRING_DISTANCES',
    sql: 'CREATE OR REPLACE TABLE `${output_table}` AS SELECT t.${h3_column} AS input, `@@BQ_DATASET@@.H3_KRING_DISTANCES`(t.${h3_column}, ${size}) AS kring FROM ${source_table} t'
});