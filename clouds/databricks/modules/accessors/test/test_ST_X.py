from databricks import sql
import os

def run_query(query):
    query = query.replace('@@DB_SCHEMA@@', "carto_dev_data")
    with sql.connect(server_hostname = os.getenv("DATABRICKS_SERVER_HOSTNAME"),
                    http_path       = os.getenv("DATABRICKS_HTTP_PATH"),
                    access_token    = os.getenv("DATABRICKS_TOKEN")) as connection:

        with connection.cursor() as cursor:
            cursor.execute(query)
            return cursor.fetchall()

def test_st_x_success():
    query = "SELECT @@DB_SCHEMA@@.st_x(geom) as latitude from @@DB_SCHEMA@@.points_100k limit 100;"
    result = run_query(query)
    assert result[0][0] == -91.855484




