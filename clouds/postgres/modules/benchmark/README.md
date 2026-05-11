# Postgres Module Benchmark

Per-function timing benchmarks. Each `benchmark(...)` call iterates the configured cases for that function, runs the SQL once per case, prints a markdown row, and appends to `clouds/postgres/dist/benchmark_<UTC-timestamp>.md`.

## Setup

```bash
cd clouds/postgres/modules/benchmark
cp config.template.json config.json   # gitignored — edit your tables/values here
```

## Running

Same `modules=` / `functions=` filter as `make test`:

```bash
cd clouds/postgres
make benchmark                                  # all
make benchmark modules=h3                       # one module
make benchmark modules=h3 functions=H3_KRING    # one benchmark
```

Each `make benchmark` run writes a new file named `benchmark_<UTC-timestamp>.md` (ISO 8601 form `YYYY-MM-DDTHH-MM-SSZ`) so runs are isolated, sortable, and easy to diff. Override the destination with `BENCHMARK_RESULTS_FILE=<path>`.

For procedures that create output tables, pass `keep=1` to leave the tables in place after the run for inspection — the pre-case drop still runs so each invocation starts clean:

```bash
make benchmark functions=SOME_TABLE_PROC keep=1
```

## Config

Each function entry is a list of cases. Each case is self-contained — duplication is fine. Param keys mirror the function's documented signature (`H3_KRING(origin, size)` → `size`); meta keys (`source_table`, `h3_column`, `output_table`) stay descriptive.

```json
{
    "H3_KRING": [
        {"source_table": "@@PG_SCHEMA@@.sample_table", "h3_column": "h3", "size": 1},
        {"source_table": "@@PG_SCHEMA@@.sample_table", "h3_column": "h3", "size": 2}
    ],
    "H3_POLYFILL": [
        {"source_table": "@@PG_SCHEMA@@.polygons", "geom_column": "geom", "resolution": 9}
    ]
}
```

If a function isn't in `config.json`, the benchmark emits a `skipped: no entry for <FN> in config.json` row instead of running.

## Output

```markdown
# Benchmark run — 2026-05-11T14:32:18Z

| Function       | Params                                              | Time (s) | Error |
|---|---|---|---|
| H3_KRING       | source_table=...sample, h3_column=h3, size=2        | 1.81     | - |
| H3_POLYFILL    | resolution=9                                        | 0.80     | - |
```

One file per `make benchmark` run; all functions in a single table — no per-file sub-headings.

Error column: `-` (success), `skipped: <reason>`, or first line of the exception (truncated, pipes escaped). `bench()` catches exceptions, so one failure doesn't kill the run. Long values in Params are truncated to ~60 chars.

## Authoring

SQL templates use `${name}` placeholders (`string.Template` syntax) for substitution against the merged config + per-call params. `${name}` rather than Python's `.format()` `{name}` so SQL containing literal `{` / `}` (JSON, etc.) works without escaping.

Most benchmarks are a single `benchmark(...)` call:

```python
# Copyright (c) 2026, CARTO
from benchmark_utils import benchmark

benchmark(
    function='H3_KRING',
    sql='SELECT COUNT(*) FROM ${source_table} t, '
        'UNNEST(@@PG_SCHEMA@@.H3_KRING(t.${h3_column}, ${size})) AS k',
)
```

Then add at least one case to `config.json`. Run with `make benchmark functions=H3_KRING`.

### Procedures with output tables

Pass a `cleanup=` list of table-name templates. They're dropped before AND after each case (so cleanup time isn't counted in the timing, and orphans from previous failed runs are cleared up front):

```python
benchmark(
    function='SOME_OUTPUT_PROC',
    sql='CREATE TABLE ${output_table} AS SELECT ...',
    cleanup=['${output_table}'],
)
```

### Lower-level: manual loop with `bench()`

If you need per-case dispatch (e.g. different SQL per mode), use the lower-level `bench()` directly:

```python
from benchmark_utils import bench, config_for

SQL_BY_MODE = {
    'center': '...',
    'intersects': '...',
}
for case in config_for('H3_POLYFILL_MODE'):
    bench(
        function='H3_POLYFILL_MODE',
        params=case,
        sql=SQL_BY_MODE[case['mode']],
    )
```
