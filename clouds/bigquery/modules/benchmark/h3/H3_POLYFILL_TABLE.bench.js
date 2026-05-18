const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_POLYFILL_TABLE',
    sql: "CALL `@@BQ_DATASET@@.H3_POLYFILL_TABLE`('${input_query}', ${resolution}, '${mode}', '${output_table}')"
});