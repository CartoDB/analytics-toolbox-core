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
    return text


def run_queries(queries):
    global function
    with sql.connect(
        server_hostname=os.getenv('DB_HOST_NAME'),
        http_path=os.getenv('DB_HTTP_PATH'),
        access_token=os.getenv('DB_TOKEN'),
    ) as conn:
        with conn.cursor() as cursor:
            for i in trange(len(queries), ncols=97):
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
            run_queries(split(content))
        except Exception as error:
            error_msg = str(error)
            print(f'[{function}] ERROR: {error_msg}')
            exit(1)
