const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_POLYFILL_TABLE',
    sql: "CALL @@SF_SCHEMA@@.QUADBIN_POLYFILL_TABLE('${input_query}', ${resolution}, '${mode}', '${output_table}')"
});