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
    try:
        return cursor.fetchall()
    except:
        return 'No results returned'

def run_queries(queries):
    conn = redshift_connector.connect(
        host=os.environ['RS_HOST'],
        database=os.environ['RS_DATABASE'],
        user=os.environ['RS_USER'],
        password=os.environ['RS_PASSWORD'],
    )
    cursor = conn.cursor()
    for query in queries:
        cursor.execute(query.replace('@@RS_PREFIX@@', os.environ['RS_SCHEMA_PREFIX']))
    try:
        return cursor.fetchall()
    except:
        return 'No results returned'

def get_cursor():
    conn = redshift_connector.connect(
        host=os.environ['RS_HOST'],
        database=os.environ['RS_DATABASE'],
        user=os.environ['RS_USER'],
        password=os.environ['RS_PASSWORD'],
    )
    return conn.cursor()