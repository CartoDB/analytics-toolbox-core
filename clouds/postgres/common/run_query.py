import os
import sys
import psycopg2


def run_query(query):
    with psycopg2.connect(
        host=os.environ['PG_HOST'],
        database=os.environ['PG_DATABASE'],
        user=os.environ['PG_USER'],
        password=os.environ['PG_PASSWORD'],
        port=5432,
    ) as conn:
        conn.autocommit = True
        with conn.cursor() as cursor:
            cursor.execute(query)


if __name__ == '__main__':
    query = sys.argv[1]
    run_query(query)
