import os, sys
from databricks import sql


def run_query(query):
    with sql.connect(
        server_hostname=os.getenv('DB_HOST_NAME'),
        http_path=os.getenv('DB_HTTP_PATH'),
        access_token=os.getenv('DB_TOKEN'),
    ) as conn:
        with conn.cursor() as cursor:
            cursor.execute(query)
            return cursor.fetchall()


if __name__ == '__main__':
    query = sys.argv[1]
    run_query(query)
