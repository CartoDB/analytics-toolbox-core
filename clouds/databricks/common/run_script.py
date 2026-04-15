import os
import re
import sys

from tqdm import trange
from sqlparse import split
from databricks import sql

function = ''


def apply_replacements(text):
    if os.environ.get('REPLACEMENTS'):
        replacements = os.environ.get('REPLACEMENTS').split(' ')
        for replacement in replacements:
            if replacement:
                pattern = re.compile(f'@@{replacement}@@', re.MULTILINE)
                text = pattern.sub(os.environ.get(replacement, ''), text)
    # Add the missing backtick unescaping (like build_modules.js line 149)
    text = text.replace('\\`', '`')
    return text


def split_sql(content):
    """Split SQL content into individual statements.

    Uses sqlparse.split() but post-processes the results to re-split
    any parts that contain multiple CREATE OR REPLACE statements.
    sqlparse sometimes merges Databricks SQL compound statements
    (BEGIN...END with IF/WHILE/CASE blocks) with following statements.
    """
    parts = split(content)
    result = []
    create_pattern = re.compile(
        r'\n(?=CREATE\s+OR\s+REPLACE\s)', re.IGNORECASE
    )
    for part in parts:
        stripped = part.strip()
        if not stripped:
            continue
        # Check if this part contains multiple CREATE OR REPLACE statements
        count = len(re.findall(
            r'(?:^|\n)\s*CREATE\s+OR\s+REPLACE\s', stripped, re.IGNORECASE
        ))
        if count <= 1:
            result.append(stripped)
        else:
            # Re-split on CREATE OR REPLACE boundaries
            sub_parts = create_pattern.split(part)
            for i, sub in enumerate(sub_parts):
                sub = sub.strip()
                if sub:
                    # Re-add the CREATE keyword for parts after the first
                    if i > 0 and not sub.upper().startswith('CREATE'):
                        sub = 'CREATE ' + sub
                    result.append(sub)
    return result


def run_queries(queries):
    global function
    with sql.connect(
        server_hostname=os.getenv('DB_HOST_NAME'),
        http_path=os.getenv('DB_HTTP_PATH'),
        access_token=os.getenv('DB_TOKEN'),
    ) as conn:
        with conn.cursor() as cursor:
            for i in trange(len(queries), dynamic_ncols=True, leave=True, position=0):
                query = apply_replacements(queries[i])
                pattern = os.environ['DB_SCHEMA'] + '.(.*?)[(|\n]'
                result = re.search(pattern, query)
                if result:
                    function = result.group(1)
                cursor.execute(query)


if __name__ == '__main__':
    script = sys.argv[1]

    with open(script, 'r') as file:
        content = file.read()

    if os.environ.get('SKIP_PROGRESS_BAR'):
        try:
            run_queries([content])
        except Exception as error:
            error_msg = str(error)
            print(f'ERROR: {error_msg}')
            exit(1)
    else:
        try:
            run_queries(split_sql(content))
        except Exception as error:
            error_msg = str(error)
            print(f'[{function}] ERROR: {error_msg}')
            exit(1)
