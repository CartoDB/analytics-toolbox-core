"""Per-function timing benchmarks for Oracle modules. Sibling of test_utils."""
import json
import os
import sys
import time
from string import Template

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from test_utils import run_query, drop_table  # noqa: E402

__all__ = ['benchmark', 'bench', 'config_for']

# Process-global. Each Make-driven invocation runs each benchmark file in
# its own Python process. BENCHMARK_HEADER_WRITTEN signals Make-mode:
# Make wrote the markdown table header in the results file already, and
# bench() should keep stdout quiet (only the per-function summary in
# benchmark() prints — Jest-style).
_HEADER_PRINTED = False
_CONFIG_CACHE = None
_RESULTS_PATH_CACHE = None
_MISSING_CONFIG = '__missing_config__'


def _config_dir():
    here = os.path.dirname(os.path.abspath(__file__))
    return os.path.abspath(os.path.join(here, '..', '..', 'modules', 'benchmark'))


def _load_config():
    global _CONFIG_CACHE
    if _CONFIG_CACHE is not None:
        return _CONFIG_CACHE

    local_path = os.path.join(_config_dir(), 'config.json')
    template_path = os.path.join(_config_dir(), 'config.template.json')

    if os.path.isfile(local_path):
        path = local_path
    elif os.path.isfile(template_path):
        path = template_path
        sys.stderr.write(
            f'[benchmark] Using {template_path}; '
            f'copy it to config.json to override.\n'
        )
    else:
        _CONFIG_CACHE = {}
        return _CONFIG_CACHE

    try:
        with open(path) as f:
            _CONFIG_CACHE = json.load(f)
    except json.JSONDecodeError as e:
        sys.stderr.write(f'[benchmark] Failed to parse {path}: {e}\n')
        _CONFIG_CACHE = {}
    return _CONFIG_CACHE


def config_for(function):
    """Return the list of cases configured for `function`.

    If the function has no entry in config.json, returns a single sentinel
    case so bench() can emit a clear "no config entry" skip row instead of
    silently producing no output.
    """
    entry = _load_config().get(function)
    if not entry:  # None, [], or any other falsy → treat as missing
        return [{_MISSING_CONFIG: True}]
    if not isinstance(entry, list):
        entry = [entry]
    return entry


def _results_path():
    """Resolve the per-run results file. Cached so all bench() calls share it."""
    global _RESULTS_PATH_CACHE
    if _RESULTS_PATH_CACHE:
        return _RESULTS_PATH_CACHE
    env_path = os.environ.get('BENCHMARK_RESULTS_FILE')
    if env_path:
        path = env_path
    else:
        ts = time.strftime('%Y-%m-%dT%H-%M-%SZ', time.gmtime())
        path = os.path.join(os.getcwd(), 'dist', f'benchmark_{ts}.md')
    os.makedirs(os.path.dirname(path) or '.', exist_ok=True)
    _RESULTS_PATH_CACHE = path
    return path


def _quiet():
    return bool(os.environ.get('BENCHMARK_HEADER_WRITTEN'))


def _ensure_header():
    """Write the markdown table header once per process. Skipped in Make-mode."""
    global _HEADER_PRINTED
    if _HEADER_PRINTED or _quiet():
        _HEADER_PRINTED = True
        return
    _HEADER_PRINTED = True
    header = '\n| Function | Params | Time (s) | Error |\n|---|---|---|---|\n'
    sys.stdout.write(header)
    with open(_results_path(), 'a') as f:
        f.write(header)


def _format_params(params, max_value_len=60):
    if not params:
        return '-'
    parts = []
    for k, v in params.items():
        s = str(v)
        if len(s) > max_value_len:
            s = s[: max_value_len - 3] + '...'
        parts.append(f'{k}={s}')
    return ', '.join(parts)


def _sanitize_error(exc):
    return str(exc).split('\n', 1)[0][:120].replace('|', r'\|')


def benchmark(function, sql, cleanup=None):
    """Run all configured cases for `function`.

    cleanup: list of table-name templates (with `${placeholders}`) to drop
    before AND after each case. Skipped when the function has no config
    entry (sentinel case) so the missing-config path doesn't crash.

    Set BENCHMARK_KEEP_OUTPUT=1 (or run `make benchmark keep=1`) to skip
    the post-case drops so output tables can be inspected. Pre-case drops
    still happen so each run starts from clean state.

    Emits one Jest-style summary line per function:
        ✓ FUNCTION (1.23s)            all cases passed
        - FUNCTION (no config)        no entry in config.json
        ✗ FUNCTION (1/3 failed)       at least one case errored
    """
    cleanup = cleanup or []
    keep = bool(os.environ.get('BENCHMARK_KEEP_OUTPUT'))
    counts = {'pass': 0, 'fail': 0, 'skip': 0, 'no_config': 0}
    total_time = 0.0

    for case in config_for(function):
        is_missing = case.get(_MISSING_CONFIG, False)
        tables = [] if is_missing else [Template(t).substitute(**case) for t in cleanup]
        for tbl in tables:
            drop_table(tbl)
        try:
            status, elapsed = bench(function=function, params=case, sql=sql)
        finally:
            if not keep:
                for tbl in tables:
                    drop_table(tbl)
        total_time += elapsed
        counts[status] += 1

    total = sum(counts.values())
    if counts['fail']:
        line = f'✗ {function} ({counts["fail"]}/{total} failed)'
    elif counts['no_config'] == total:
        line = f'- {function} (no config)'
    elif counts['pass'] == 0:
        skipped_total = counts['skip'] + counts['no_config']
        line = f'- {function} ({skipped_total} skipped)'
    else:
        suffix = f'{total_time:.2f}s'
        skipped_total = counts['skip'] + counts['no_config']
        if skipped_total:
            suffix += f', {skipped_total} skipped'
        line = f'✓ {function} ({suffix})'
    sys.stdout.write(line + '\n')


def bench(function, sql, params=None, skip_reason=None):
    """Run one case. Returns (status, elapsed_seconds).

    status ∈ {'pass', 'skip', 'fail'}.
    Writes a markdown row to the results file always; to stdout only when
    not in Make-mode (so direct `python <file>` runs are still verbose).
    """
    _ensure_header()

    is_missing_config = bool(params and params.pop(_MISSING_CONFIG, False))
    if is_missing_config:
        skip_reason = f'no entry for {function} in config.json'

    params_str = _format_params(params)
    elapsed = 0.0
    status = 'pass'

    if skip_reason:
        time_str = 'n/a'
        error_str = f'skipped: {skip_reason}'
        status = 'no_config' if is_missing_config else 'skip'
    else:
        try:
            final_sql = Template(sql).substitute(**(params or {}))
            start = time.perf_counter()
            run_query(final_sql)
            elapsed = time.perf_counter() - start
            time_str = f'{elapsed:.2f}'
            error_str = '-'
        except Exception as e:
            time_str = 'n/a'
            error_str = _sanitize_error(e)
            status = 'fail'

    row = f'| {function} | {params_str} | {time_str} | {error_str} |'

    if not _quiet():
        sys.stdout.write(row + '\n')
    with open(_results_path(), 'a') as f:
        f.write(row + '\n')

    return status, elapsed
