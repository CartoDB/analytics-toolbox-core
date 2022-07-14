import os
import re

import geopandas as gpd
import pandas as pd
import psycopg2

from shapely import wkt
from sqlalchemy import create_engine

PG_CONFIG = {
    'host': os.environ['PG_HOST'],
    'database': os.environ['PG_DATABASE'],
    'user': os.environ['PG_USER'],
    'password': os.environ['PG_PASSWORD'],
    'port': 5432,
}
CONNECT_OPTIONS = f"-c search_path={os.environ['PG_SCHEMA']},pg_catalog,public"
# SQLAlchemy connection fails if pg_catalog is overriden
# See: https://github.com/sqlalchemy/sqlalchemy/issues/6912
SQLALCHEMY_CONNECT_OPTIONS = f"-c search_path={os.environ['PG_SCHEMA']},public"


conn = psycopg2.connect(options=CONNECT_OPTIONS, **PG_CONFIG)
conn.autocommit = (
    True  # Needed for running procedures since they must be out of a transaction
)

connection_string = 'postgresql://{user}:{password}@{host}:{port}/{database}'.format(
    **PG_CONFIG
)
engine = create_engine(
    connection_string, connect_args={'options': SQLALCHEMY_CONNECT_OPTIONS}
)


def run_query_without_result(query):
    cursor = conn.cursor()
    cursor.execute(query)


def run_query(query):
    cursor = conn.cursor()
    cursor.execute(query)
    return cursor.fetchall()


def drop_table(table):
    run_query_without_result(f'DROP TABLE {table}')


def upload_csv_to_postgres(table):
    """Read a CSV file, convert to a GeoDataFrame and upload to the DB"""
    df = pd.read_csv(f'test/integration/fixtures/{table}.csv')
    gdf = gpd.GeoDataFrame(df, geometry=df.geom.map(wkt.loads))
    gdf = gdf.drop(columns=['geom'])
    gdf = gdf.rename(columns={'geometry': 'geom'})
    gdf = gdf.set_geometry('geom')
    gdf = gdf.set_crs(epsg=4326)
    gdf.to_postgis(table, engine, if_exists='replace')


def upload_nogeom_csv_to_postgres(table):
    """Read a CSV file, convert to a DataFrame and upload to the DB"""
    df = pd.read_csv(f'test/integration/fixtures/{table}.csv')
    df.to_sql(table, engine, if_exists='replace')


def floats_approx_equal(a, b, rel_tol=1e-5, abs_tol=0.0):
    # for Python >= 3.5: math.isclose(a, b, rel_tol, abs_tol):
    return abs(a-b) <= max(rel_tol * max(abs(a), abs(b)), abs_tol)


numbers = re.compile(r'^(?:([-+]?\d*\.?\d+)(?:[eE]([-+]?\d+))?\,?)+$')


def split_numbers(n):
    return [float(x) for x in n.split(',')]


def floats_list_approx_equal(alist, blist, rel_tol=1e-5, abs_tol=0.0):
    if len(alist) != len(blist):
        return False
    for a, b in zip(alist, blist):
        if not floats_approx_equal(a, b, rel_tol, abs_tol):
            return False
    return True


def dicts_approx_equal(a, b, rel_tol=1e-5, abs_tol=0.0):
    if (a == b):
        return True
    a_keys = a.keys()
    b_keys = b.keys()
    if (a_keys != b_keys):
        return False
    for key in a_keys:
        a_value = a.get(key)
        b_value = b.get(key)
        if a_value != b_value:
            a_type = type(a_value)
            b_type = type(b_value)
            if a_type != b_type:
                return False
            if a_type == dict:
                if not dicts_approx_equal(a_value, b_value, rel_tol, abs_tol):
                    return False
            elif a_type == float:
                if not floats_approx_equal(a_value, b_value, rel_tol, abs_tol):
                    return False
            elif a_type == str:
                if numbers.match(a_value) and numbers.match(b_value):
                    a_values = split_numbers(a_value)
                    b_values = split_numbers(b_value)
                    if not floats_list_approx_equal(
                        a_values, b_values, rel_tol, abs_tol
                    ):
                        return False
                elif a_value != b_value:
                    return False
    return True
