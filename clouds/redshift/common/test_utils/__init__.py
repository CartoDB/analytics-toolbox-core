import os
import redshift_connector

from redshift_connector.error import ProgrammingError

__all__ = ['ProgrammingError']


def run_query(query):
    conn = redshift_connector.connect(
        host=os.environ['RS_HOST'],
        database=os.environ['RS_DATABASE'],
        user=os.environ['RS_USER'],
        password=os.environ['RS_PASSWORD'],
    )
    conn.autocommit = True
    cursor = conn.cursor()
    cursor.execute(query.replace('@@RS_SCHEMA@@', os.environ['RS_SCHEMA']))
    try:
        return cursor.fetchall()
    except Exception:
        return 'No results returned'


def run_queries(queries):
    conn = redshift_connector.connect(
        host=os.environ['RS_HOST'],
        database=os.environ['RS_DATABASE'],
        user=os.environ['RS_USER'],
        password=os.environ['RS_PASSWORD'],
    )
    # conn.autocommit is False by default. Set to True to avoid the following error:
    # COMMIT cannot be invoked from a procedure that is executing in an atomic context.
    conn.autocommit = True
    cursor = conn.cursor()
    for query in queries:
        cursor.execute(query.replace('@@RS_SCHEMA@@', os.environ['RS_SCHEMA']))
    try:
        return cursor.fetchall()
    except Exception:
        return 'No results returned'


def get_cursor():
    conn = redshift_connector.connect(
        host=os.environ['RS_HOST'],
        database=os.environ['RS_DATABASE'],
        user=os.environ['RS_USER'],
        password=os.environ['RS_PASSWORD'],
    )
    return conn.cursor()
