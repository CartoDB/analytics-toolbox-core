// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_RESOLUTION',
    sql: 'CREATE OR REPLACE TABLE `${output_table}` AS SELECT `@@BQ_DATASET@@.H3_RESOLUTION`(t.${h3_column}) AS result FROM ${source_table} t'
});