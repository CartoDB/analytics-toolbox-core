# Snowflake Module Benchmark

Per-function timing benchmarks. Each `benchmark(...)` call iterates the configured cases for that function, runs the SQL once per case, prints a markdown row, and appends to `clouds/snowflake/dist/benchmark_<UTC-timestamp>.md`.

Mirrors the Oracle and BigQuery benchmark scaffolding (`clouds/oracle/modules/benchmark/`, `clouds/bigquery/modules/benchmark/`) — same shape, same config-driven model, same Jest-style summary lines — so cross-cloud comparisons stay structurally aligned.

## Setup

```bash
cd clouds/snowflake/modules/benchmark
cp config.template.json config.json   # gitignored — edit your tables/values here
```

## Running

Same `modules=` / `functions=` filter as `make test`:

```bash
cd clouds/snowflake
make benchmark                                  # all
make benchmark modules=h3                       # one module
make benchmark modules=h3 functions=H3_KRING    # one benchmark
```

Each `make benchmark` run writes a new file named `benchmark_<UTC-timestamp>.md` so runs are isolated, sortable, and easy to diff. Override the destination with `BENCHMARK_RESULTS_FILE=<path>`.

## Connection cost

The Snowflake connection is established + `SELECT 1` warmup is run *before* each `bench()` timer starts, so timings reflect query execute + fetch only — not connection establishment.

## Config

Each function entry is a list of cases. Each case is self-contained — duplication is fine. Param keys mirror the function's documented signature (`H3_KRING(origin, size)` → `size`); meta keys (`source_table`, `h3_column`) stay descriptive.

```json
{
    "H3_KRING": [
        {"source_table": "MYDB.MYSCHEMA.H3_TABLE", "h3_column": "H3", "size": 1},
        {"source_table": "MYDB.MYSCHEMA.H3_TABLE", "h3_column": "H3", "size": 2}
    ]
}
```

If a function isn't in `config.json`, the benchmark emits a `skipped: no entry for <FN> in config.json` row.

## Output

```markdown
# Benchmark run — 2026-05-08T14:32:18Z

| Function | Params | Time (s) | Error |
|---|---|---|---|
| H3_KRING | source_table=MYDB.MYSCHEMA.H3_TABLE, h3_column=H3, size=2 | 1.81 | - |
```

One file per `make benchmark` run; all functions in a single table. Error column: `-` (success), `skipped: <reason>`, or first line of the exception (truncated, pipes escaped). Long values in Params are truncated to ~60 chars.

## Authoring

SQL templates use `${name}` placeholders. Snowflake's array-unnest is `LATERAL FLATTEN(input => array)` (vs BigQuery's `UNNEST` and Oracle's `TABLE(...)`).

```js
// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_KRING',
    sql: `SELECT COUNT(*) FROM \${source_table} t,
LATERAL FLATTEN(input => @@SF_SCHEMA@@.H3_KRING(t.\${h3_column}, \${size}))`
});
```
