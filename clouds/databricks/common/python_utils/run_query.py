import os, sys
from databricks import sql


def run_query(query):
    query = query.replace('@@DB_SCHEMA@@', os.getenv('DB_SCHEMA'))
    with sql.connect(
        server_hostname=os.getenv('DB_HOST'),
        http_path=os.getenv('DB_HTTP_PATH'),
        access_token=os.getenv('DB_TOKEN'),
    ) as connection:

        with connection.cursor() as cursor:
            cursor.execute(query)
            return cursor.fetchall()


if __name__ == '__main__':
    query = sys.argv[1]
    run_query(query)
