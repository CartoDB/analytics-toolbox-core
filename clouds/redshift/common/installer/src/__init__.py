import os
import re
import sys
import yaml
import click
import zipfile
import redshift_connector

from tqdm import trange
from sqlparse import split


def read_config(filename):
    try:
        with open(filename, 'r') as yamlfile:
            config = yaml.load(yamlfile, Loader=yaml.FullLoader)
            validate_config(config)
        return config
    except FileNotFoundError:
        exit(f'ERROR: configuration file not found: {filename}')


def read_package(filename):
    with zipfile.ZipFile(filename, 'r') as zip_ref:
        folder = zip_ref.infolist()[0].filename
        zip_ref.extractall('.')

    with open(os.path.join(folder, 'libraries.sql'), 'r') as lib_file:
        libraries = lib_file.read()

    with open(os.path.join(folder, 'modules.sql'), 'r') as mod_file:
        modules = mod_file.read()

    return {'libraries': libraries, 'modules': modules}


def run_sql(sql, config):
    with redshift_connector.connect(
        host=config['connection']['host'],
        database=config['connection']['database'],
        user=config['connection']['user'],
        password=config['connection']['password'],
    ) as conn:
        conn.autocommit = True
        with conn.cursor() as cursor:
            queries = split(
                sql.replace('@@API_BASE_URL@@', config['lds']['api_base_url'])
                .replace('@@LDS_LAMBDA@@', config['lds']['lambda'])
                .replace('@@LDS_ROLES@@', config['lds']['roles'])
                .replace('@@LDS_TOKEN@@', config['lds']['token'])
            )
            for i in trange(len(queries), ncols=100):
                query = queries[i]
                cursor.execute(query)


def validate_config(config):
    connection = config.get('connection')
    lds = config.get('lds')

    if connection is None:
        exit('incorrect configuration: missing connection')

    pattern = r'^([^.]+)\.([^.]+)\.([^.]+)\.redshift(-serverless)?\.amazonaws\.com$'
    if not validate_str(connection.get('host'), pattern):
        exit('incorrect configuration: missing or invalid connection.host')

    if not validate_str(connection.get('database')):
        exit('incorrect configuration: missing connection.database')

    if not validate_str(connection.get('user')):
        exit('incorrect configuration: missing connection.user')

    if not validate_str(connection.get('password')):
        exit('incorrect configuration: missing connection.password')

    if lds is None:
        exit('incorrect configuration: missing lds')

    pattern = r'^(lds-function-asia-northeast1|lds-function-australia-southeast1|lds-function-europe-west1|lds-function-us-east1)$'  # noqa: E501
    if not validate_str(lds.get('lambda'), pattern):
        exit('incorrect configuration: missing or invalid lds.lambda')

    pattern = r'^arn:aws:iam::[0-9]+:role/CartoFunctionsRedshiftRole,arn:aws:iam::000955892807:role/CartoFunctionsRole$'  # noqa: E501
    if not validate_str(lds.get('roles'), pattern):
        exit('incorrect configuration: missing or invalid lds.roles')

    if not validate_str(lds.get('api_base_url')):
        exit('incorrect configuration: missing lds.api_base_url')

    if not validate_str(lds.get('token')):
        exit('incorrect configuration: missing lds.token')


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
    package = read_package(package_file)
    print('Installing libraries...')
    run_sql(package['libraries'], config)
    print('Installing modules...')
    run_sql(package['modules'], config)