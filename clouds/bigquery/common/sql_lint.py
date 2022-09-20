"""List and fix SQL files."""

import os
import sys
import sqlfluff
import multiprocessing as mp


def lint_error(name, error):
    code = error['code']
    line_no = error['line_no']
    line_pos = error['line_pos']
    description = error['description']
    print(f'{name}:{line_no}:{line_pos}: {code} {description}')


def fix_and_lint(script):
    name = ''
    content = ''
    with open(script, 'r') as file:
        name = os.path.basename(file.name)
        content = (
            file.read()
            .replace('@@BQ_DATASET@@', '_SQLFLUFFDATASET_')
            .replace('@', '_SQLFLUFF_')
        )

    fix = (
        sqlfluff.fix(content, dialect='bigquery', config_path=sys.argv[2])
        .replace('_sqlfluffdataset_', '@@BQ_DATASET@@')
        .replace('_SQLFLUFFDATASET_', '@@BQ_DATASET@@')
        .replace('_sqlfluff_', '@')
        .replace('_SQLFLUFF_', '@')
    )
    if content != fix:
        with open(script, 'w') as file:
            file.write(fix)

    lint = sqlfluff.lint(fix, dialect='bigquery', config_path=config_file)
    if lint:
        error = True
        for error in lint:
            print(error)
            lint_error(name, error)


if __name__ == '__main__':
    scripts = sys.argv[1].split(' ')
    config_file = sys.argv[2]
    ignored_files = sys.argv[3]
    if ignored_files:
        with open(ignored_files, 'r') as ignored_file:
            ignored_scripts = ignored_file.read().split('\n')
        for ignored_script in ignored_scripts:
            scripts = list(filter(lambda x: not x.endswith(ignored_script), scripts))

    pool = mp.Pool(processes=int(mp.cpu_count() / 2))
    pool.map(fix_and_lint, scripts)
