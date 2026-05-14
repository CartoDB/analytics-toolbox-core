// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_UNCOMPACT',
    sql: 'CREATE OR REPLACE TABLE `${output_table}` AS SELECT `@@BQ_DATASET@@.H3_UNCOMPACT`(ARRAY_AGG(${h3_column}), ${resolution}) AS expanded FROM ${source_table}'
});