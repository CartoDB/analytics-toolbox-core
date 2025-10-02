"""List and fix Databricks SQL files."""

import os
import sys
import sqlfluff
import multiprocessing as mp

DIALECT = 'databricks'


def replace_variables(content):
    # FIXME: provisionally we replace database.table names by database_sqlfluffdot_table
    # to circumvent a problem with the sqlfluff SparkSQL parser
    # Also note that the parser requires the name not to start with an underscore.
    # And that fix may convert names to uppercase.
    return content.replace('@.', '@_SQLFLUFFDOT_').replace('@', 'SQLFLUFF_')


def restore_variables(content):
    return content.replace('SQLFLUFF_', '@').replace('_SQLFLUFFDOT_', '.')


def lint_error(name, error):
    code = error.get('code', 'UNKNOWN')
    line_no = error.get('line_no', 0)
    line_pos = error.get('line_pos', 0)
    description = error.get('description', 'Unknown error')
    print(f'{name}:{line_no}:{line_pos}: {code} {description}')


def fix_and_lint(script):
    if not script or not os.path.exists(script):
        return False
    
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
        has_error = True
        for error in lint:
            lint_error(name, error)

        return has_error


if __name__ == '__main__' and sys.argv[1]:
    scripts = [s for s in sys.argv[1].split(' ') if s.strip()]
    ignored_files = sys.argv[3] if len(sys.argv) > 3 else None
    if ignored_files and os.path.exists(ignored_files):
        with open(ignored_files, 'r') as ignored_file:
            ignored_scripts = [s.strip() for s in ignored_file.read().split('\n') if s.strip()]
        for ignored_script in ignored_scripts:
            scripts = list(filter(lambda x: not x.endswith(ignored_script), scripts))

    pool = mp.Pool(processes=int(mp.cpu_count() / 2))
    output = pool.map(fix_and_lint, scripts)

    if any(output):
        sys.exit(1)
