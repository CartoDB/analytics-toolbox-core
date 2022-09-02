import os
from databricks import sql


def run_query(query):
    query = query.replace('@@DB_SCHEMA@@', os.getenv('DB_SCHEMA'))
    with sql.connect(
        server_hostname=os.getenv('DATABRICKS_SERVER_HOSTNAME'),
        http_path=os.getenv('DATABRICKS_HTTP_PATH'),
        access_token=os.getenv('DATABRICKS_TOKEN'),
    ) as connection:

        with connection.cursor() as cursor:
            cursor.execute(query)
            return cursor.fetchall()
