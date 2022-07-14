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


floats_list = re.compile(r"""
    ^
    (?:[-+]?\d*\.?\d+)(?:E([-+]?\d+))?     # first float
    (?:                                    # optional sequence of:
        \s*\,\s*                             # separator
        (?:[-+]?\d*\.?\d+)(?:E([-+]?\d+))?   # additional float
    )*
    $
    """, re.IGNORECASE | re.VERBOSE)


def split_floats_list(n):
    return [float(x) for x in n.split(',')]


def floats_list_approx_equal(alist, blist, rel_tol=1e-5, abs_tol=0.0):
    if len(alist) != len(blist):
        return False
    for a, b in zip(alist, blist):
        if not floats_approx_equal(a, b, rel_tol, abs_tol):
            return False
    return True


def values_approx_equal(a, b, rel_tol=1e-5, abs_tol=0.0):
    return len(values_approx_diff(a, b, rel_tol, abs_tol, '', True)) == 0


def values_approx_diff_message(indent, a, b, rel_tol=1e-5, abs_tol=0.0):
    diffs = values_approx_diff(a, b, rel_tol, abs_tol)
    return '\n'.join([indent + msg for msg in diffs])


def lists_approx_diff(a, b, rel_tol=1e-5, abs_tol=0.0, key_prefix='', only_first=False):
    spec = ' ' if key_prefix == '' else f' of "{key_prefix}" '
    diffs = []
    if (a == b):
        return diffs
    if len(a) != len(b):
        diffs.append(f'Lengths{spec}differ')
    else:
        for i, (a_value, b_value) in enumerate(zip(a, b)):
            item_desc = f'{key_prefix}[{i}]' if key_prefix != '' else f'element {i}'
            diffs += values_approx_diff(
                a_value, b_value, rel_tol, abs_tol, item_desc, only_first)
        if only_first and len(diffs) > 0:
            return diffs
    return diffs


def values_approx_diff(
    a_value, b_value, rel_tol=1e-5, abs_tol=0.0, key_prefix='', only_first=False
):
    spec = ' ' if key_prefix == '' else f' of "{key_prefix}" '
    diffs = []
    if (a_value == b_value):
        return diffs
    a_type = type(a_value)
    b_type = type(b_value)
    if a_type != b_type:
        diffs.append(f'Types{spec}differ')
    if a_type == list:
        diffs += lists_approx_diff(
            a_value, b_value, rel_tol, abs_tol, key_prefix, only_first)
    elif a_type == tuple:
        diffs += lists_approx_diff(
            list(a_value), list(b_value), rel_tol, abs_tol, key_prefix, only_first)
    elif a_type == dict:
        diffs += dicts_approx_diff(
            a_value, b_value, rel_tol, abs_tol, key_prefix, only_first)
    elif a_type == float:
        if not floats_approx_equal(a_value, b_value, rel_tol, abs_tol):
            diffs.append(f'Values{spec}too different: {a_value} vs {b_value}')
    elif a_type == str:
        if floats_list.match(a_value) and floats_list.match(b_value):
            a_values = split_floats_list(a_value)
            b_values = split_floats_list(b_value)
            if not floats_list_approx_equal(a_values, b_values, rel_tol, abs_tol):
                diffs.append(f'Values{spec}too different: {a_value} vs {b_value}')
        elif a_value != b_value:
            diffs.append(f'Values{spec}differ: "{a_value}" vs "{b_value}"')
    elif a_value != b_value:
        diffs.append(f'Values{spec}differ: "{a_value}" vs "{b_value}"')
    return diffs


def dicts_approx_diff(a, b, rel_tol=1e-5, abs_tol=0.0, key_prefix='', only_first=False):
    if key_prefix != '':
        key_prefix = key_prefix + '.'
    diffs = []
    if (a == b):
        return diffs
    a_keys = a.keys()
    b_keys = b.keys()
    if (a_keys != b_keys):
        anotb_keys = [key for key in a_keys if key not in b_keys]
        bnota_keys = [key for key in b_keys if key not in a_keys]
        diffs += [f'Key "{key_prefix + key}" only in first' for key in anotb_keys]
        diffs += [f'Key "{key_prefix + key}" only in second' for key in bnota_keys]
        if only_first:
            return diffs
    for key in a_keys:
        if key not in b_keys:
            continue
        a_value = a.get(key)
        b_value = b.get(key)
        diffs += values_approx_diff(
            a_value, b_value, rel_tol, abs_tol, key_prefix + key, only_first)
        if only_first and len(diffs) > 0:
            return diffs
    return diffs
