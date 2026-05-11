// Copyright (c) 2026, CARTO
//
// Snowflake doesn't have a separate H3_POLYFILL_MODE function — H3_POLYFILL
// is overloaded with an optional mode argument. This bench file targets that
// 3-arg form so cross-cloud results align with Oracle/BigQuery's
// H3_POLYFILL_MODE benchmark.

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_POLYFILL_MODE',
    sql: 'SELECT COUNT(*) FROM ${source_table} t,\n' +
         "LATERAL FLATTEN(input => @@SF_SCHEMA@@.H3_POLYFILL(t.${geom_column}, ${resolution}, '${mode}'))"
});