"""Per-function timing benchmarks for Oracle modules. Sibling of test_utils."""
import json
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from test_utils import run_query  # noqa: E402

__all__ = ['bench', 'config_for']

_FILE_HEADER_PRINTED_FOR = set()
_CONFIG_CACHE = None


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
    if entry is None:
        return [{'__missing_config__': True}]
    if not isinstance(entry, list):
        entry = [entry]
    return entry


def _results_path():
    default = os.path.join(os.getcwd(), 'dist', 'benchmark_results.md')
    path = os.environ.get('BENCHMARK_RESULTS_FILE', default)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    return path


def _ensure_file_header(caller_file):
    if caller_file in _FILE_HEADER_PRINTED_FOR:
        return
    _FILE_HEADER_PRINTED_FOR.add(caller_file)
    rel = os.path.relpath(caller_file, os.path.dirname(_results_path()))
    header = (
        '\n'.join(
            [
                '',
                f'### {rel}',
                '',
                '| Function | Params | Time (s) | Error |',
                '|---|---|---|---|',
            ]
        )
        + '\n'
    )
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
    msg = str(exc).split('\n', 1)[0][:200].replace('|', r'\|')
    return msg


def bench(function, sql, params=None, skip_reason=None):
    caller_file = sys._getframe(1).f_globals.get('__file__', '<unknown>')
    _ensure_file_header(caller_file)

    if params and params.pop('__missing_config__', False):
        skip_reason = f'no entry for {function} in config.json'

    params_str = _format_params(params)

    if skip_reason:
        time_str = 'n/a'
        error_str = f'skipped: {skip_reason}'
    else:
        try:
            final_sql = sql.format(**(params or {}))
            start = time.perf_counter()
            run_query(final_sql)
            elapsed = time.perf_counter() - start
            time_str = f'{elapsed:.2f}'
            error_str = '-'
        except Exception as e:
            time_str = 'n/a'
            error_str = _sanitize_error(e)

    row = f'| {function} | {params_str} | {time_str} | {error_str} |'

    sys.stdout.write(row + '\n')
    with open(_results_path(), 'a') as f:
        f.write(row + '\n')
