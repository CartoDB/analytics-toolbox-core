"""Benchmark utilities for Oracle modules.

Sibling of test_utils. Provides `bench(name, sql, mode, skip_reason)` for
per-function timing benchmarks that print a markdown row to stdout and
append to clouds/oracle/benchmark_results.md (location overridable via
the BENCHMARK_RESULTS_FILE env var).

Used by clouds/oracle/modules/benchmarks/<module>/benchmark_<FUNCTION>.py
files invoked via `make benchmark` (which sets PYTHONPATH and
BENCHMARK_RESULTS_FILE).
"""
import os
import sys
import time

# Reuse the existing test_utils.run_query (and its connection caching).
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from test_utils import run_query  # noqa: E402

__all__ = ['bench']

_FILE_HEADER_PRINTED_FOR = set()


def _results_path():
    """Resolve benchmark_results.md location.

    Override via BENCHMARK_RESULTS_FILE env var; otherwise CWD-based so that
    `cd clouds/oracle && make benchmark` writes alongside the version file.
    """
    return os.environ.get(
        'BENCHMARK_RESULTS_FILE',
        os.path.join(os.getcwd(), 'benchmark_results.md'),
    )


def _ensure_file_header(caller_file):
    """On first bench() call from a given source file, append a sub-section header."""
    if caller_file in _FILE_HEADER_PRINTED_FOR:
        return
    _FILE_HEADER_PRINTED_FOR.add(caller_file)
    rel = os.path.relpath(caller_file, os.path.dirname(_results_path()))
    header = '\n'.join([
        '',
        f'### {rel}',
        '',
        '| Workload | Mode | Time (s) |',
        '|---|---|---|',
    ]) + '\n'
    sys.stdout.write(header)
    with open(_results_path(), 'a') as f:
        f.write(header)


def bench(name, sql, mode='-', skip_reason=None):
    """Run one timed query, write a markdown row to stdout + benchmark_results.md.

    Single run, no warmup, no median — keep it simple. Re-run an individual
    file (`make benchmark functions=<NAME>`) if a result looks off.
    """
    caller_file = sys._getframe(1).f_globals.get('__file__', '<unknown>')
    _ensure_file_header(caller_file)

    if skip_reason:
        row = f'| {name} | {mode} | n/a (skipped: {skip_reason}) |'
    else:
        start = time.perf_counter()
        run_query(sql)
        elapsed = time.perf_counter() - start
        row = f'| {name} | {mode} | {elapsed:.2f} |'

    sys.stdout.write(row + '\n')
    with open(_results_path(), 'a') as f:
        f.write(row + '\n')
