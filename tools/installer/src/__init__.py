import os
import re
import sys
import yaml
import click
import zipfile
import redshift_connector
import jwt
from validator_collection import checkers

from tqdm import trange
from sqlparse import split
from psycopg2 import connect


def read_config(filename):
    try:
        with open(filename, 'r') as yamlfile:
            config = yaml.load(yamlfile, Loader=yaml.FullLoader)
            validate_config(config)
        return config
    except FileNotFoundError:
        exit(f'ERROR: configuration file not found: {filename}')


def read_package(filename, config):
    with zipfile.ZipFile(filename, 'r') as zip_ref:
        folder = zip_ref.infolist()[0].filename
        zip_ref.extractall('.')

    package = {}

    if config['connection']['cloud'] == 'redshift':
        with open(os.path.join(folder, 'libraries.sql'), 'r') as lib_file:
            package['libraries'] = lib_file.read()

    with open(os.path.join(folder, 'modules.sql'), 'r') as mod_file:
        package['modules'] = mod_file.read()

    return package


def run_sql(sql, config):
    if config['connection']['cloud'] == 'redshift':
        with redshift_connector.connect(
            host=config['connection']['host'],
            database=config['connection']['database'],
            user=config['connection']['user'],
            password=config['connection']['password'],
        ) as conn:
            conn.autocommit = True
            with conn.cursor() as cursor:
                lds = config.get('lds')
                if lds is not None:
                    sql = (
                        sql.replace('@@API_BASE_URL@@', lds['api_base_url'])
                        .replace('@@LDS_LAMBDA@@', lds['lambda'])
                        .replace('@@LDS_ROLES@@', lds['roles'])
                        .replace('@@LDS_TOKEN@@', lds['token'])
                    )
                queries = split(sql)
                for i in trange(len(queries), ncols=100):
                    query = queries[i]
                    cursor.execute(query)
    elif config['connection']['cloud'] == 'postgres':
        with connect(
            host=config['connection']['host'],
            database=config['connection']['database'],
            user=config['connection']['user'],
            password=config['connection']['password'],
        ) as conn:
            conn.autocommit = True
            with conn.cursor() as cursor:
                queries = split(sql)
                for i in trange(len(queries), ncols=97):
                    query = queries[i]
                    cursor.execute(query)
            for notice in list(set(conn.notices)):
                print(notice.strip())


def validate_lds_config(lds_config):
    pattern = r'^(lds-function-asia-northeast1|lds-function-australia-southeast1|lds-function-europe-west1|lds-function-us-east1)$'  # noqa: E501
    if not validate_str(lds_config.get('lambda'), pattern):
        exit('incorrect configuration: missing or invalid lds.lambda')

    pattern = r'^arn:aws:iam::[0-9]+:role/CartoFunctionsRedshiftRole,arn:aws:iam::000955892807:role/CartoFunctionsRole$'  # noqa: E501
    if not validate_str(lds_config.get('roles'), pattern):
        exit('incorrect configuration: missing or invalid lds.roles')

    if not validate_str(lds_config.get('api_base_url')):
        exit('incorrect configuration: missing lds.api_base_url')

    if not checkers.is_url(lds_config.get('api_base_url')):
        exit('incorrect configuration: invalid lds.api_base_url')

    token = lds_config.get('token')
    if not validate_str(token):
        exit('incorrect configuration: missing lds.token')
    algorithm = jwt.get_unverified_header(token).get('alg')
    if not algorithm:
        exit('incorrect configuration: invalid lds.token')
    jwt_payload = jwt.decode(
        token, algorithms=[algorithm], options={'verify_signature': False}
    )
    if not jwt_payload.get('a') or not jwt_payload.get('jti'):
        exit('incorrect configuration: invalid lds.token')


def validate_config(config):
    connection = config.get('connection')

    cloud = connection.get('cloud')
    if not validate_str(cloud):
        exit('incorrect configuration: missing connection.cloud')

    if cloud not in ['redshift', 'postgres']:
        exit('incorrect configuration: invalid connection.cloud')

    if connection is None:
        exit('incorrect configuration: missing connection')

    if not validate_str(connection.get('host')):
        exit('incorrect configuration: missing connection.host')

    if cloud == 'redshift':
        pattern = r'^([^.]+)\.([^.]+)\.([^.]+)\.redshift(-serverless)?\.amazonaws\.com$'
        if not validate_str(connection.get('host'), pattern):
            exit('incorrect configuration: invalid connection.host')

    if not validate_str(connection.get('database')):
        exit('incorrect configuration: missing connection.database')

    if not validate_str(connection.get('user')):
        exit('incorrect configuration: missing connection.user')

    if not validate_str(connection.get('password')):
        exit('incorrect configuration: missing connection.password')

    lds_config = config.get('lds')
    if cloud == 'redshift' and lds_config is not None:
        validate_lds_config(lds_config)


def validate_str(string, pattern=None):
    return (
        isinstance(string, str)
        and len(string) > 0
        and (not pattern or re.compile(pattern).match(string))
    )


def exit(message):
    print(f'ERROR: {message}')
    sys.exit(1)


@click.command(help='Python installer for the CARTO Analytics Toolbox in Redshift.')
@click.argument('package_file', type=click.Path(exists=True), required=True)
def main(package_file):
    config_file = 'config.yml'
    print(f'Reading config file: {config_file}')
    config = read_config(config_file)
    print(f'Reading package file: {package_file}')
    package = read_package(package_file, config)
    if 'libraries' in package:
        print('Installing libraries...')
        run_sql(package['libraries'], config)
    print('Installing modules...')
    run_sql(package['modules'], config)
