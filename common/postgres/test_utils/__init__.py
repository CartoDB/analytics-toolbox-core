import os

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
