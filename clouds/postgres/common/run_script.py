import os
import re
import sys

from tqdm import trange
from sqlparse import split
from psycopg2 import connect

function = ''


def run_queries(queries):
    global function
    with connect(
        host=os.environ['PG_HOST'],
        database=os.environ['PG_DATABASE'],
        user=os.environ['PG_USER'],
        password=os.environ['PG_PASSWORD'],
    ) as conn:
        conn.autocommit = True
        with conn.cursor() as cursor:
            for i in trange(len(queries), ncols=97):
                query = queries[i]
                pattern = os.environ['PG_SCHEMA'] + '.(.*?)[(|\n]'
                result = re.search(pattern, query)
                if result:
                    function = result.group(1)
                cursor.execute(query)
        for notice in list(set(conn.notices)):
            print(notice.strip())


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
