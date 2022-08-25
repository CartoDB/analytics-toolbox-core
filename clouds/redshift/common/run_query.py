import os
import sys
import redshift_connector


def run_query(query):
    with redshift_connector.connect(
        host=os.environ['RS_HOST'],
        database=os.environ['RS_DATABASE'],
        user=os.environ['RS_USER'],
        password=os.environ['RS_PASSWORD'],
    ) as conn:
        conn.autocommit = True
        with conn.cursor() as cursor:
            cursor.execute(query)


if __name__ == '__main__':
    query = sys.argv[1]
    run_query(query)
