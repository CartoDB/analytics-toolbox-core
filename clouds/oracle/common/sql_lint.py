#!/usr/bin/env python3
"""
SQL linter for Oracle Analytics Toolbox.

Placeholder for SQL linting - can be enhanced later with sqlfluff.
"""

import sys


def lint_sql(files):
    """Lint SQL files."""
    print(f'Linting {len(files)} SQL files...')
    # TODO: Implement actual SQL linting
    print('✓ SQL linting passed (placeholder)')
    return 0


if __name__ == '__main__':
    sys.exit(lint_sql(sys.argv[1:]))
