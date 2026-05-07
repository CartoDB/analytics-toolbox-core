# Oracle Module Benchmark

Per-function timing benchmarks. Each `bench(...)` call runs SQL once, prints a markdown row, appends to `clouds/oracle/dist/benchmark_results.md`.

## Setup

```bash
cd clouds/oracle/modules/benchmark
cp config.template.json config.json   # gitignored — edit your tables/values here
```

## Running

Same `modules=` / `functions=` filter as `make test`:

```bash
cd clouds/oracle
make benchmark                                  # all
make benchmark modules=h3                       # one module
make benchmark modules=h3 functions=H3_KRING    # one benchmark
```

`make benchmark` prepends `## Benchmark run — <UTC>` to `benchmark_results.md` per invocation. Override the destination with `BENCHMARK_RESULTS_FILE=<path>`.

## Config

Each function entry is a list of cases. Each case is self-contained — duplication is fine. Param keys mirror the function's documented signature (`H3_KRING(origin, size)` → `size`); meta keys (`source_table`, `h3_column`, `output_table`) stay descriptive.

```json
{
    "H3_KRING": [
        {"source_table": "@@ORA_SCHEMA@@.NYC_TAXI", "h3_column": "h3", "size": 1},
        {"source_table": "@@ORA_SCHEMA@@.NYC_TAXI", "h3_column": "h3", "size": 2}
    ],
    "H3_POLYFILL": [
        {"geog": "POLYGON((-3.85 40.30, -3.55 40.30, -3.55 40.55, -3.85 40.55, -3.85 40.30))", "resolution": 9}
    ]
}
```

## Output

```markdown
| Function          | Params                                      | Time (s) | Error |
|---|---|---|---|
| H3_KRING          | source_table=...NYC_TAXI, h3_column=h3, size=2 | 1.81 | - |
| H3_POLYFILL       | mode=intersects, resolution=9               | 0.80     | - |
| H3_POLYFILL       | mode=contains, resolution=9                 | n/a      | skipped: contains mode not supported on Oracle v1.0 |
| H3_POLYFILL_TABLE | output_table=...BAD                         | n/a      | ORA-00942: table or view does not exist |
```

Error column: `-` (success), `skipped: <reason>`, or first line of the exception (truncated, pipes escaped). `bench()` catches exceptions, so one failure doesn't kill the run.

## Authoring

```python
# Copyright (c) 2026, CARTO
from benchmark_utils import bench, config_for

for case in config_for('H3_KRING'):
    bench(
        function='H3_KRING',
        params=case,
        sql='SELECT COUNT(*) FROM {source_table} t, '
            'TABLE(@@ORA_SCHEMA@@.H3_KRING(t.{h3_column}, {size}))',
    )
```

Then add at least one case to `config.json`. Run with `make benchmark functions=H3_KRING`.

### Structural variants (different SQL per case)

Dispatch via a small map keyed on a case attribute:

```python
SQL_BY_MODE = {
    'center':     "SELECT COUNT(*) FROM TABLE(@@ORA_SCHEMA@@.H3_POLYFILL("
                  "SDO_UTIL.FROM_WKTGEOMETRY('{geog}'), {resolution}))",
    'intersects': "SELECT COUNT(*) FROM TABLE(@@ORA_SCHEMA@@.__H3_POLYFILL_MODE("
                  "SDO_UTIL.FROM_WKTGEOMETRY('{geog}'), {resolution}, 'intersects'))",
}

for case in config_for('H3_POLYFILL'):
    mode = case.get('mode', 'center')
    bench(
        function='H3_POLYFILL',
        params=case,
        sql=SQL_BY_MODE[mode],
        skip_reason='contains mode not supported on Oracle v1.0' if mode == 'contains' else None,
    )
```

### Procedures with output tables

Cleanup lives outside `bench()` so the timing is just the procedure:

```python
from benchmark_utils import bench, config_for
from test_utils import drop_table

for case in config_for('H3_POLYFILL_TABLE'):
    drop_table(case['output_table'])
    try:
        bench(function='H3_POLYFILL_TABLE', params=case, sql='BEGIN ... END;')
    finally:
        drop_table(case['output_table'])
```
