// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_POLYFILL_MODE',
    sql: "CREATE OR REPLACE TABLE `${output_table}` AS SELECT `@@BQ_DATASET@@.H3_POLYFILL_MODE`(t.${geom_column}, ${resolution}, '${mode}') AS cells FROM ${source_table} t"
});