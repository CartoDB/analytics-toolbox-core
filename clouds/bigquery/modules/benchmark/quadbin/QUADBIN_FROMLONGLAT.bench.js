// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_FROMLONGLAT',
    sql: 'CREATE OR REPLACE TABLE `${output_table}` AS SELECT `@@BQ_DATASET@@.QUADBIN_FROMLONGLAT`(${longitude}, ${latitude}, ${resolution}) AS result FROM ${source_table}'
});