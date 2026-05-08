// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_POLYFILL_TABLE',
    sql: 'CALL `@@BQ_DATASET@@.H3_POLYFILL_TABLE`(\'${input_query}\', ${resolution}, \'${mode}\', \'${output_table}\')',
    cleanup: ['${output_table}']
});