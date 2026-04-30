---
badges:
---
# quadbin

You can learn more about Quadbins in the [Spatial Indexes section](https://docs.carto.com/data-and-analysis/analytics-toolbox-for-oracle/key-concepts/spatial-indexes#quadbin) of the documentation.

The `QUADBIN_POLYFILL_TABLE` stored procedure available in BigQuery is not provided in Oracle: `QUADBIN_POLYFILL` is already a pipelined function and can be used directly inside `INSERT … SELECT` to materialize a table.
