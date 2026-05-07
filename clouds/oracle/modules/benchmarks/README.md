# Oracle Module Benchmarks

Per-function timing benchmarks for the Oracle modules. Each benchmark runs once, prints a markdown row to stdout, and appends to `clouds/oracle/benchmark_results.md`.

## Layout

```
clouds/oracle/modules/benchmarks/
├── h3/
│   └── benchmark_H3_<FUNCTION>.py
└── quadbin/
    └── benchmark_QUADBIN_<FUNCTION>.py
```

One file per function. Multi-mode functions (e.g. `H3_POLYFILL`) emit one row per mode within a single file.

## Running

Filter shape mirrors `make test` — `modules=` and `functions=`:

```bash
cd clouds/oracle

make benchmark                                  # all benchmarks
make benchmark modules=h3                       # all H3 benchmarks
make benchmark modules=h3 functions=H3_KRING    # one specific benchmark
```

`make benchmark` prepends a timestamped section header (`## Benchmark run — <UTC>`) to `benchmark_results.md` before running each matching file.

For an isolated re-run after a fix, invoke the file directly (no Make header is added — just the per-file `### filename` sub-section + the timing row(s)):

```bash
python modules/benchmarks/h3/benchmark_H3_KRING.py
```

## Output format

Each `bench(...)` call emits one row:

```markdown
| Workload                       | Mode       | Time (s) |
|---|---|---|
| H3_KRING(h3, 2)                | -          | 1.81 |
| H3_POLYFILL(<bbox>, res)       | center     | 0.64 |
| H3_POLYFILL(<bbox>, res)       | intersects | 0.80 |
| H3_POLYFILL(<bbox>, res)       | contains   | n/a (skipped: contains mode not supported on Oracle v1.0) |
```

Single timed run, no warmup, no median. Re-run the file if a result looks off (cold cache, jitter, etc.).

## Tweaking the source table

Each benchmark file has `SOURCE_TABLE` and related constants at the top. Edit per dev environment:

```python
SOURCE_TABLE = '@@ORA_SCHEMA@@.MY_TABLE'
H3_COLUMN = 'h3'
```

`@@ORA_SCHEMA@@` is replaced at query time by `test_utils.run_query` from the `ORA_SCHEMA` env var (set in `clouds/oracle/.env`).

## Persistence

Results accumulate in `clouds/oracle/benchmark_results.md` (gitignored). Each Make run adds a top-level `## Benchmark run — <timestamp>` section; each per-file invocation adds a `### filename` sub-section underneath. Direct file invocations append a sub-section without a parent header.

## Authoring a new benchmark

```python
# clouds/oracle/modules/benchmarks/<module>/benchmark_<FUNCTION>.py
from test_utils import bench

SOURCE_TABLE = '@@ORA_SCHEMA@@.SAMPLE_TABLE'
COLUMN = 'h3'

if __name__ == '__main__':
    bench(
        name='<FUNCTION>(args)',
        sql=f'SELECT COUNT(*) FROM {SOURCE_TABLE} t, TABLE(@@ORA_SCHEMA@@.<FUNCTION>(t.{COLUMN}))',
    )
```

For multi-mode (one row per mode):

```python
for mode in ['center', 'intersects', 'contains']:
    bench(
        name='<FUNCTION>(<bbox>, res)',
        mode=mode,
        sql=...,                      # SQL specific to the mode
        skip_reason=...                # set when a mode is not supported
    )
```
