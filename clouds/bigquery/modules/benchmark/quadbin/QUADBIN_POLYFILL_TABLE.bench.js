// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_POLYFILL_TABLE',
    sql: 'CALL `@@BQ_DATASET@@.QUADBIN_POLYFILL_TABLE`(\'${input_query}\', ${resolution}, \'${mode}\', \'${output_table}\')',
    cleanup: ['${output_table}']
});