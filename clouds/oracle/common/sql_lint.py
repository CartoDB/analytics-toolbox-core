"""List Oracle SQL files (lint-only — no auto-fix).

Oracle uses PL/SQL, which sqlfluff parses imperfectly. Auto-fixing has
been observed to produce semantically wrong changes (e.g. qualifying a
function parameter as if it were a column reference, like turning
`variables` into `JT.VARIABLES` inside a JSON_TABLE call). Therefore
this script reports lint violations as warnings but does NOT call
sqlfluff.fix(). Developers should review violations and apply fixes
manually when appropriate.
"""

import os
import sys
import sqlfluff
import multiprocessing as mp

DIALECT = 'oracle'


def replace_variables(content):
    # Oracle identifiers cannot start with underscore, so the placeholders
    # use a plain alphanumeric prefix that sqlfluff's oracle dialect can lex.
    return content.replace('@@ORA_SCHEMA@@', 'SQLFLUFFSCHEMA').replace(
        '@', 'SQLFLUFFAT'
    )


def lint_error(name, error):
    code = error.get('code', 'UNKNOWN')
    line_no = error.get('start_line_no', 0)
    line_pos = error.get('start_line_pos', 0)
    description = error.get('description', 'Unknown error')
    print(f'{name}:{line_no}:{line_pos}: {code} {description}')


def lint_only(script):
    if not script:
        return False
    with open(script, 'r') as file:
        name = os.path.basename(file.name)
        content = replace_variables(file.read())

    lint = sqlfluff.lint(content, dialect=DIALECT, config_path=sys.argv[2])
    if lint:
        has_error = False
        for error in lint:
            if 'Found unparsable section' not in error['description']:
                has_error = True
                lint_error(name, error)

        return has_error


if __name__ == '__main__':
    scripts = [s for s in sys.argv[1].split(' ') if s]
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
    output = pool.map(lint_only, scripts)

    if any(output):
        sys.exit(1)
