# BigQuery Module Benchmark

Per-function timing benchmarks. Each `benchmark(...)` call iterates the configured cases for that function, runs the SQL once per case, prints a markdown row, and appends to `clouds/bigquery/dist/benchmark_<UTC-timestamp>.md`.

Mirrors the Oracle benchmark scaffolding (`clouds/oracle/modules/benchmark/`) — same shape, same config-driven model, same Jest-style summary lines — so cross-cloud comparisons stay structurally aligned.

## Setup

```bash
cd clouds/bigquery/modules/benchmark
cp config.template.json config.json   # gitignored — edit your tables/values here
```

## Running

Same `modules=` / `functions=` filter as `make test`:

```bash
cd clouds/bigquery
make benchmark                                  # all
make benchmark modules=h3                       # one module
make benchmark modules=h3 functions=H3_KRING    # one benchmark
```

Each `make benchmark` run writes a new file named `benchmark_<UTC-timestamp>.md` so runs are isolated, sortable, and easy to diff. Override the destination with `BENCHMARK_RESULTS_FILE=<path>`.

For procedures that create output tables (e.g. `H3_POLYFILL_TABLE`), pass `keep=1` to leave the tables in place after the run for inspection — the pre-case drop still runs so each invocation starts clean:

```bash
make benchmark functions=H3_POLYFILL_TABLE keep=1
```

## Connection cost

The BigQuery client and its first auth/HTTP handshake are pre-warmed (`SELECT 1`) before each `bench()` timer starts, so timings reflect query execute + fetch only — not connection establishment.

## Config

Each function entry is a list of cases. Each case is self-contained — duplication is fine. Param keys mirror the function's documented signature (`H3_KRING(origin, size)` → `size`); meta keys (`source_table`, `h3_column`, `output_table`) stay descriptive.

```json
{
    "H3_KRING": [
        {"source_table": "myproject.mydataset.h3_table", "h3_column": "h3", "size": 1},
        {"source_table": "myproject.mydataset.h3_table", "h3_column": "h3", "size": 2}
    ],
    "H3_POLYFILL": [
        {"source_table": "myproject.mydataset.polygons_table", "geom_column": "geom", "resolution": 8}
    ]
}
```

If a function isn't in `config.json`, the benchmark emits a `skipped: no entry for <FN> in config.json` row instead of running.

## Output

```markdown
# Benchmark run — 2026-05-08T14:32:18Z

| Function          | Params                                      | Time (s) | Error |
|---|---|---|---|
| H3_KRING          | source_table=...h3_table, h3_column=h3, size=2 | 1.81 | - |
| H3_POLYFILL       | source_table=...polygons, geom_column=geom, resolution=8 | 0.80 | - |
| H3_POLYFILL_TABLE | input_query=..., resolution=8, mode=center  | n/a      | <error first line> |
```

One file per `make benchmark` run; all functions in a single table — no per-file sub-headings.

Error column: `-` (success), `skipped: <reason>`, or first line of the exception (truncated, pipes escaped). `bench()` catches exceptions, so one failure doesn't kill the run. Long values in Params are truncated to ~60 chars.

## Authoring

SQL templates use `${name}` placeholders (substituted against the merged config + per-call params). `${name}` rather than backtick-template-literal interpolation so SQL containing literal `{` / `}` (JSON, struct literals) works without escaping. Benchmark files use JS template literals with `\${...}` escapes for the placeholders and `\`` escapes for BQ identifier backticks.

Most benchmarks are a single `benchmark(...)` call:

```js
// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_KRING',
    sql: `SELECT COUNT(*) FROM \`\${source_table}\` t,
UNNEST(\`@@BQ_DATASET@@.H3_KRING\`(t.\${h3_column}, \${size})) AS k`,
});
```

Then add at least one case to `config.json`. Run with `make benchmark functions=H3_KRING`.

### Procedures with output tables

Pass a `cleanup:` list of fully-qualified table-name templates. They're dropped before AND after each case (so cleanup time isn't counted in the timing, and orphans from previous failed runs are cleared up front):

```js
benchmark({
    function: 'H3_POLYFILL_TABLE',
    sql: `CALL \`@@BQ_DATASET@@.H3_POLYFILL_TABLE\`('\${input_query}', \${resolution}, '\${mode}', '\${output_table}')`,
    cleanup: ['${output_table}'],
});
```

Cleanup uses `DROP TABLE IF EXISTS \`<fq-name>\`` so it's safe whether or not the table exists.
