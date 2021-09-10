import os
import redshift_connector


def run_query(query):
    conn = redshift_connector.connect(
        host=os.environ['RS_HOST'],
        database=os.environ['RS_DATABASE'],
        user=os.environ['RS_USER'],
        password=os.environ['RS_PASSWORD'],
    )
    cursor = conn.cursor()
    cursor.execute(query.replace('@@RS_PREFIX@@', os.environ['RS_SCHEMA_PREFIX']))
    return cursor.fetchall()
