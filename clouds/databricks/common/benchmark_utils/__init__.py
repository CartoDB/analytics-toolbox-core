"""Per-function timing benchmarks for Databricks modules. Sibling of test_utils."""
import atexit
import json
import os
import sys
import time
from string import Template

from databricks import sql as dbsql

__all__ = ['benchmark', 'bench', 'config_for']

# Connection-establishment time would otherwise be charged to whichever
# bench() call happens first. Cache one connection per process and
# pre-warm before each timer starts so timings reflect query work only.
_BENCH_CONN = None


def _close_bench_conn():
    global _BENCH_CONN
    if _BENCH_CONN is not None:
        try:
            _BENCH_CONN.close()
        except Exception:
            pass
        _BENCH_CONN = None


def _get_bench_conn():
    global _BENCH_CONN
    if _BENCH_CONN is None:
        _BENCH_CONN = dbsql.connect(
            server_hostname=os.environ['DB_HOST_NAME'],
            http_path=os.environ['DB_HTTP_PATH'],
            access_token=os.environ['DB_TOKEN'],
            _disable_pandas=True,
        )
        atexit.register(_close_bench_conn)
    return _BENCH_CONN


def _run_query_timed(sql):
    """Execute on the cached connection. Used inside the timer window."""
    sql = sql.replace('@@DB_SCHEMA@@', os.environ.get('DB_SCHEMA', ''))
    sql = sql.replace('\\`', '`')
    cursor = _get_bench_conn().cursor()
    try:
        cursor.execute(sql)
        try:
            return cursor.fetchall()
        except Exception:
            return None
    finally:
        cursor.close()


def _drop_table_safe(table_name):
    """Best-effort DROP TABLE used by benchmark()'s cleanup arg."""
    sql = f'DROP TABLE IF EXISTS {table_name}'.replace(
        '@@DB_SCHEMA@@', os.environ.get('DB_SCHEMA', ''),
    )
    try:
        cursor = _get_bench_conn().cursor()
        try:
            cursor.execute(sql)
        finally:
            cursor.close()
    except Exception:
        pass


# Process-global. Each Make-driven invocation runs each benchmark file in
# its own Python process. BENCHMARK_HEADER_WRITTEN signals Make-mode:
# Make wrote the markdown table header in the results file already, and
# bench() should keep stdout quiet (only the per-function summary in
# benchmark() prints — Jest-style).
_HEADER_PRINTED = False
_CONFIG_CACHE = None
_RESULTS_PATH_CACHE = None
_MISSING_CONFIG = '__missing_config__'
_VERBOSE = bool(os.environ.get('BENCHMARK_VERBOSE'))


def _drop_bench_table(fqn):
    """Best-effort pre/post-run drop of benchmark output table."""
    fqn = fqn.replace('@@DB_SCHEMA@@', os.environ.get('DB_SCHEMA', ''))
    sql = f'DROP TABLE IF EXISTS {fqn}'
    cursor = _get_bench_conn().cursor()
    try:
        cursor.execute(sql)
    except Exception:
        pass
    finally:
        cursor.close()


def _config_dir():
    # Set by each modules/Makefile; root's export wins over core's `?=`.
    env = os.environ.get('BENCHMARK_CONFIG_DIR')
    if env:
        return os.path.abspath(env)
    # Fallback for direct `python <bench>` invocation (no Make involved).
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
    """Return the list of cases configured for `function`."""
    entry = _load_config().get(function)
    if not entry:
        return [{_MISSING_CONFIG: True}]
    if not isinstance(entry, list):
        entry = [entry]
    tags_filter = os.environ.get('BENCHMARK_TAGS', '').strip()
    if tags_filter:
        wanted = {t.strip() for t in tags_filter.split(',') if t.strip()}
        if wanted:
            entry = [c for c in entry if wanted & set(c.get('tags') or [])]
    return entry


def _results_path():
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
    global _HEADER_PRINTED
    if _HEADER_PRINTED or _quiet():
        _HEADER_PRINTED = True
        return
    _HEADER_PRINTED = True
    keep = bool(os.environ.get('BENCHMARK_KEEP_OUTPUT'))
    header = (
        '\n| Function | Params | Time (s) | Error | Output Table |\n'
        '|---|---|---|---|---|\n'
        if keep else
        '\n| Function | Params | Time (s) | Error |\n|---|---|---|---|\n'
    )
    sys.stdout.write(header)
    with open(_results_path(), 'a') as f:
        f.write(header)


def _format_params(params, max_value_len=60):
    if not params:
        return '-'
    parts = []
    for k, v in params.items():
        if k in ('output_table', 'tags'):
            continue
        s = str(v)
        if len(s) > max_value_len:
            s = s[: max_value_len - 3] + '...'
        parts.append(f'{k}={s}')
    return ', '.join(parts) or '-'


def _sanitize_error(exc):
    msg = str(exc)
    if _VERBOSE:
        return msg.replace('\n', ' ').replace('|', r'\|')
    return msg.split('\n', 1)[0][:120].replace('|', r'\|')


def benchmark(function, sql, cleanup=None):
    """Run all configured cases for `function`."""
    cleanup = cleanup or []
    keep = bool(os.environ.get('BENCHMARK_KEEP_OUTPUT'))
    counts = {'pass': 0, 'fail': 0, 'skip': 0, 'no_config': 0}
    total_time = 0.0

    for case in config_for(function):
        is_missing = case.get(_MISSING_CONFIG, False)
        tables = [] if is_missing else [Template(t).substitute(**case) for t in cleanup]
        for tbl in tables:
            _drop_table_safe(tbl)
        try:
            status, elapsed = bench(function=function, params=case, sql=sql)
        finally:
            if not keep:
                for tbl in tables:
                    _drop_table_safe(tbl)
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
    """Run one case. Returns (status, elapsed_seconds)."""
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
        output_table = (params or {}).get('output_table')
        try:
            final_sql = Template(sql).substitute(**(params or {}))
            _get_bench_conn()
            if output_table:
                _drop_bench_table(output_table)
            start = time.perf_counter()
            _run_query_timed(final_sql)
            elapsed = time.perf_counter() - start
            time_str = f'{elapsed:.2f}'
            error_str = '-'
        except Exception as e:
            time_str = 'n/a'
            error_str = _sanitize_error(e)
            status = 'fail'
        finally:
            if output_table and not bool(os.environ.get('BENCHMARK_KEEP_OUTPUT')):
                _drop_bench_table(output_table)

    output_table_display = (params or {}).get('output_table', '-').replace(
        '@@DB_SCHEMA@@', os.environ.get('DB_SCHEMA', ''),
    )
    output_table_col = (
        f' {output_table_display} |'
        if bool(os.environ.get('BENCHMARK_KEEP_OUTPUT')) else ''
    )
    row = f'| {function} | {params_str} | {time_str} | {error_str} |{output_table_col}'

    if not _quiet():
        sys.stdout.write(row + '\n')
    with open(_results_path(), 'a') as f:
        f.write(row + '\n')

    return status, elapsed
