import os
import re
import sys

from tqdm import trange
from sqlparse import split
from redshift_connector import connect
from redshift_connector.error import ProgrammingError

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
    with connect(
        host=os.environ['RS_HOST'],
        database=os.environ['RS_DATABASE'],
        user=os.environ['RS_USER'],
        password=os.environ['RS_PASSWORD'],
    ) as conn:
        conn.autocommit = True
        filter = os.environ.get('FILTER')
        with conn.cursor() as cursor:
            for i in trange(len(queries) if not filter else 1, ncols=97):
                query = apply_replacements(queries[i])
                if (not filter) or (filter in query):
                    pattern = os.environ['RS_SCHEMA'] + '.(.*?)[(|\n]'
                    result = re.search(pattern, str(query))
                    if result:
                        function = result.group(1)
                    cursor.execute(query)


if __name__ == '__main__':
    script = sys.argv[1]

    with open(script, 'r') as file:
        content = file.read()

    try:
        run_queries(split(content))
    except ProgrammingError as error:
        error_msg = re.search("'M': '(.*?)',", str(error)).group(1)
        print(f'[{function}] ERROR: {error_msg}')
        exit(1)
