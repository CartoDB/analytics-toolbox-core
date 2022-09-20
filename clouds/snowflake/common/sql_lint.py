"""List and fix Snowflake SQL files."""

import os
import sys
import sqlfluff
import multiprocessing as mp


def replace_variables(content):
    return (
        content.replace('@@SF_SCHEMA@@._', '_SQLFLUFFSCHEMA_LD_.')
        .replace('@@SF_SCHEMA@@', '_SQLFLUFFSCHEMA_')
        .replace('@', '_SQLFLUFF_')
    )


def restore_variables(content):
    return (
        content.replace('_SQLFLUFFSCHEMA_LD_.', '@@SF_SCHEMA@@._')
        .replace('_SQLFLUFFSCHEMA_', '@@SF_SCHEMA@@')
        .replace('_SQLFLUFF_', '@')
    )


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
        content = replace_variables(file.read())

    fix = restore_variables(
        sqlfluff.fix(content, dialect='snowflake', config_path=sys.argv[2])
    )
    if content != fix:
        with open(script, 'w') as file:
            file.write(fix)

    fix = replace_variables(fix)

    lint = sqlfluff.lint(fix, dialect='snowflake', config_path=sys.argv[2])
    if lint:
        has_error = True
        for error in lint:
            lint_error(name, error)

        return has_error


if __name__ == '__main__':
    scripts = sys.argv[1].split(' ')
    ignored_files = sys.argv[3]
    if ignored_files:
        with open(ignored_files, 'r') as ignored_file:
            ignored_scripts = ignored_file.read().split('\n')
        for ignored_script in ignored_scripts:
            scripts = list(filter(lambda x: not x.endswith(ignored_script), scripts))

    pool = mp.Pool(processes=int(mp.cpu_count() / 2))
    output = pool.map(fix_and_lint, scripts)

    if any(output):
        sys.exit(1)
