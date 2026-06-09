"""List and fix BigQuery SQL files."""

import os
import re
import sys
import sqlfluff
import multiprocessing as mp

DIALECT = 'bigquery'


def replace_variables(content):
    return content.replace('@@BQ_DATASET@@', '_SQLFLUFFDATASET_').replace(
        '@', '_SQLFLUFF_'
    )


def restore_variables(content):
    # Case-insensitive: sqlfluff's capitalisation.identifiers rule may
    # lowercase the placeholder (e.g. _SQLFLUFF_ -> _sqlfluff_). A
    # case-sensitive replace would miss the lowercased form and leave
    # `_sqlfluff_xxx` corruption in BQ system variables (@@error.message)
    # and template placeholders (@@BQ_LIBRARY_X@@).
    content = re.sub('_SQLFLUFFDATASET_', '@@BQ_DATASET@@', content, flags=re.IGNORECASE)
    content = re.sub('_SQLFLUFF_', '@', content, flags=re.IGNORECASE)
    return content


def lint_error(name, error):
    code = error.get('code', 'UNKNOWN')
    line_no = error.get('start_line_no', 0)
    line_pos = error.get('start_line_pos', 0)
    description = error.get('description', 'Unknown error')
    print(f'{name}:{line_no}:{line_pos}: {code} {description}')


def fix_and_lint(script):
    name = ''
    content = ''
    with open(script, 'r') as file:
        name = os.path.basename(file.name)
        content = replace_variables(file.read())

    fix = restore_variables(
        sqlfluff.fix(content, dialect=DIALECT, config_path=sys.argv[2])
    )
    if content != fix:
        with open(script, 'w') as file:
            file.write(fix)

    fix = replace_variables(fix)

    lint = sqlfluff.lint(fix, dialect=DIALECT, config_path=sys.argv[2])
    if lint:
        has_error = False
        for error in lint:
            if 'Found unparsable section' not in error['description']:
                has_error = True
                lint_error(name, error)

        return has_error


if __name__ == '__main__':
    scripts = sys.argv[1].split(' ')
    ignored_files = sys.argv[3]
    if ignored_files:
        with open(ignored_files, 'r') as ignored_file:
            ignored_scripts = ignored_file.read().split('\n')
        for ignored_script in ignored_scripts:
            if ignored_script:
                scripts = list(
                    filter(lambda x: not x.endswith(ignored_script), scripts)
                )

    pool = mp.Pool(processes=int(mp.cpu_count() / 2))
    output = pool.map(fix_and_lint, scripts)

    if any(output):
        sys.exit(1)
