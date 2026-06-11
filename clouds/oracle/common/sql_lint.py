"""Fix and lint Oracle SQL files.

Oracle uses PL/SQL, which sqlfluff parses imperfectly. The full
`sqlfluff.fix()` ruleset has been observed to produce semantically
wrong changes (e.g. RF03 qualifying a procedure parameter as
`JT.P_SERVICE` inside a JSON_TABLE call, or ST06 reordering SELECT
columns and breaking the INTO mapping). Therefore fix is restricted to
the SAFE_FIX_RULES set below — rules that only alter casing or
whitespace and cannot change semantics. Other rules still LINT but
must be resolved manually (or excluded in .sqlfluff if appropriate).
"""

import os
import re
import sys
import sqlfluff
import multiprocessing as mp

DIALECT = 'oracle'

# Rules safe to auto-fix in Oracle PL/SQL — purely capitalisation/whitespace
# changes that cannot alter semantics:
#   CP03 (capitalisation.functions): uppercase function names.
#   CP05 (capitalisation.types): uppercase datatypes.
#   LT01 (layout.spacing): collapse unexpected line breaks / extra whitespace.
# CP02 (capitalisation.identifiers) is intentionally excluded because the
# repo distinguishes UPPERCASE constants from lowercase variables; sqlfluff
# cannot tell them apart.
SAFE_FIX_RULES = ['CP03', 'CP05', 'LT01']


def replace_variables(content):
    # Oracle identifiers cannot start with underscore, so the placeholders
    # use a plain alphanumeric prefix that sqlfluff's oracle dialect can lex.
    return content.replace('@@ORA_SCHEMA@@', 'SQLFLUFFSCHEMA').replace(
        '@', 'SQLFLUFFAT'
    )


def restore_variables(content):
    # Case-insensitive: CP02 (capitalisation.identifiers) uppercases the
    # placeholder (SQLFLUFFAT -> SQLFLUFFAT stays, but SQLFLUFFSCHEMA may be
    # split or partially cased). Use regex to restore robustly.
    content = re.sub('SQLFLUFFSCHEMA', '@@ORA_SCHEMA@@', content, flags=re.IGNORECASE)
    content = re.sub('SQLFLUFFAT', '@', content, flags=re.IGNORECASE)
    return content


def _format(name, error):
    code = error.get('code', 'UNKNOWN')
    line_no = error.get('start_line_no', 0)
    line_pos = error.get('start_line_pos', 0)
    description = error.get('description', 'Unknown error')
    return f'{name}:{line_no}:{line_pos}: {code} {description}'


def lint_error(name, error):
    print(_format(name, error))


def lint_warning(name, error):
    # sqlfluff cannot fully parse some dialect-specific constructs (BQ
    # scripting, PL/SQL bodies, etc.). Surface those as warnings so the
    # author sees them, but do not fail CI on parser limitations alone.
    print(f'[WARN] {_format(name, error)}', file=sys.stderr)


def fix_and_lint(script):
    if not script:
        return False
    with open(script, 'r') as file:
        name = os.path.basename(file.name)
        content = replace_variables(file.read())

    fix = restore_variables(
        sqlfluff.fix(
            content,
            dialect=DIALECT,
            config_path=sys.argv[2],
            rules=SAFE_FIX_RULES,
        )
    )
    if content != fix:
        with open(script, 'w') as file:
            file.write(fix)

    fix = replace_variables(fix)

    lint = sqlfluff.lint(fix, dialect=DIALECT, config_path=sys.argv[2])
    has_error = False
    for error in lint:
        if 'Found unparsable section' in error['description']:
            lint_warning(name, error)
        else:
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
    output = pool.map(fix_and_lint, scripts)

    if any(output):
        sys.exit(1)
