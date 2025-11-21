import os
from databricks import sql


def run_query(query):
    with sql.connect(
        server_hostname=os.getenv('DB_HOST_NAME'),
        http_path=os.getenv('DB_HTTP_PATH'),
        access_token=os.getenv('DB_TOKEN'),
    ) as conn:
        with conn.cursor() as cursor:
            query = query.replace('@@DB_SCHEMA@@', os.getenv('DB_SCHEMA'))
            query = query.replace('\\`', '`')
            cursor.execute(query)
            return cursor.fetchall()
